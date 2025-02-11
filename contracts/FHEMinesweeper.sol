// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.28;

import "fhevm/lib/TFHE.sol";
import { SepoliaZamaFHEVMConfig } from "fhevm/config/ZamaFHEVMConfig.sol";
import { SepoliaZamaGatewayConfig } from "fhevm/config/ZamaGatewayConfig.sol";
import "fhevm/gateway/GatewayCaller.sol";

/**
 * @title FHEMinesweeper
 * @notice A fully homomorphic encrypted (FHE) Minesweeper game contract using Zama's FHEVM.
 * @dev This contract enables encrypted gameplay where the Minesweeper board remains private.
 */
contract FHEMinesweeper is SepoliaZamaFHEVMConfig, SepoliaZamaGatewayConfig, GatewayCaller {
    uint8 public constant GRID_SIZE = 8;
    uint8 public constant NUM_MINES = 10;

    struct Game {
        bool gameActive; // Indicates if the game is in progress
        uint8 remainingSafeCells; // Counter to check if the player has won
        euint8[] board; // Encrypted board storing mines (1) and safe cells (0)
        address player; // Owner of the game session
        mapping(uint8 => bool) revealed; // Tracks revealed cells
    }

    struct PendingData {
        uint8 index;
        address player;
    }

    mapping(address => Game) public games; // Mapping of player addresses to their game states
    mapping(uint256 => PendingData) public pendingDecryptionRequests; // Track pending decryption requests

    /// @notice Emitted when a new game starts
    event GameStarted(address indexed player);

    /// @notice Emitted when a player requests to reveal a cell
    event CellRevealRequested(address indexed player, uint8 x, uint8 y, uint256 requestID);

    /// @notice Emitted when a cell is revealed
    event CellRevealed(address indexed player, uint8 x, uint8 y, uint8 value);

    /// @notice Emitted when a player loses the game by hitting a mine
    event GameLost(address indexed player);

    /// @notice Emitted when a player wins by revealing all safe cells
    event GameWon(address indexed player);

    error GameInProgress();
    error NoActiveGame();
    error InvalidCoordinates();
    error CellAlreadyRevealed();
    error InvalidDecryptionResponse();

    constructor() {}

    /**
     * @notice Starts a new Minesweeper game for the caller
     * @dev Initializes the game board and places mines in encrypted form
     */
    function startGame() external {
        require(!games[msg.sender].gameActive, GameInProgress());

        Game storage game = games[msg.sender];
        game.board = new euint8[](GRID_SIZE * GRID_SIZE);
        game.remainingSafeCells = GRID_SIZE * GRID_SIZE - NUM_MINES;
        game.gameActive = true;
        game.player = msg.sender;

        _generateBoard(game);
        emit GameStarted(msg.sender);
    }

    /**
     * @dev Generates a Minesweeper board with encrypted values
     * @param game The game structure for the player
     */
    function _generateBoard(Game storage game) private {
        euint32 random32 = TFHE.randEuint32(); // Generate a single 32-bit encrypted random number

        for (uint8 i = 0; i < 64; ) {
            // Extract a random 8-bit value (0-255) using bit shifts
            euint8 rand = TFHE.asEuint8(TFHE.shr(random32, i % 16));
            // 51/256 ≈ 19.92% probability of placing a mine
            euint8 isMine = TFHE.asEuint8(TFHE.lt(rand, 51));

            // Encrypt and store mine (1) or safe cell (0)
            game.board[i] = isMine;
            TFHE.allowThis(game.board[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Requests to reveal a cell on the game board
     * @param x The X coordinate of the cell
     * @param y The Y coordinate of the cell
     */
    function requestCellReveal(uint8 x, uint8 y) external {
        require(x < GRID_SIZE && y < GRID_SIZE, InvalidCoordinates());
        require(games[msg.sender].gameActive, NoActiveGame());

        Game storage game = games[msg.sender];
        uint8 index = x * GRID_SIZE + y;
        require(game.revealed[index] == false, CellAlreadyRevealed());

        uint256[] memory cts = new uint256[](1);
        cts[0] = Gateway.toUint256(game.board[index]);

        uint256 requestID = Gateway.requestDecryption(
            cts,
            this.cellRevealCallback.selector,
            0,
            block.timestamp + 100,
            false
        );

        pendingDecryptionRequests[requestID] = PendingData(index, msg.sender);
        emit CellRevealRequested(msg.sender, x, y, requestID);
    }

    /**
     * @notice Callback function for decryption results
     * @dev This function is called by the Gateway upon decryption completion
     * @param requestID The request ID associated with this decryption
     * @param decryptedValue The decrypted value of the cell (0 for safe, 1 for mine)
     */
    function cellRevealCallback(uint256 requestID, uint8 decryptedValue) public onlyGateway {
        PendingData memory pendingData = pendingDecryptionRequests[requestID];
        Game storage game = games[pendingData.player];

        game.revealed[pendingData.index] = true;

        if (decryptedValue == 1) {
            delete games[pendingData.player];
            emit GameLost(pendingData.player);
            return;
        }

        --game.remainingSafeCells;
        emit CellRevealed(
            pendingData.player,
            uint8(pendingData.index / GRID_SIZE),
            uint8(pendingData.index % GRID_SIZE),
            decryptedValue
        );

        if (game.remainingSafeCells == 0) {
            delete games[pendingData.player];
            emit GameWon(pendingData.player);
        }
    }
}
