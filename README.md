# Minesweeper FHE

A Fully Homomorphic Encryption (FHE) powered Minesweeper game built on [fhEVM](https://github.com/zama-ai/fhevm) using
Solidity. The game board remains encrypted on-chain, allowing players to reveal cells without exposing the full state.
This project demonstrates the use of FHE for privacy-preserving gameplay in smart contracts.

## Template

This project was build using the [fhevm-hardhat-template](https://github.com/zama-ai/fhevm-hardhat-template/generate)

## Contract Address
Contract Address on Sepolia: [0x898Cba70b3853DB431f7668068Ad38B7ce05D3f4](https://sepolia.etherscan.io/address/0x898cba70b3853db431f7668068ad38b7ce05d3f4)

## Usage

### Pre Requisites

Install [pnpm](https://pnpm.io/installation)

Before being able to run any command, you need to create a .env file and set a BIP-39 compatible mnemonic as the
`MNEMONIC` environment variable. You can follow the example in .env.example or start with the following command:

```sh
cp .env.example .env
```

If you don't already have a mnemonic, you can use this [website](https://iancoleman.io/bip39/) to generate one. An
alternative, if you have [foundry](https://book.getfoundry.sh/getting-started/installation) installed is to use the
`cast wallet new-mnemonic` command.

Then, install all needed dependencies - please **_make sure to use Node v20_** or more recent:

```sh
pnpm install
```

### Compile

Compile the smart contracts with Hardhat:

```sh
pnpm compile
```

### TypeChain

Compile the smart contracts and generate TypeChain bindings:

```sh
pnpm typechain
```

### Test

Run the tests with Hardhat - this will run the tests on a local hardhat node in mocked mode (i.e the FHE operations and
decryptions will be simulated by default):

```sh
pnpm test
```

#### Test Logs
```
❯ npx hardhat test


  FHEMinesweeper
    ✔ should allow a player to start a game (40ms)
    ✔ should prevent starting a new game while one is active (67ms)
    ✔ should prevent wrong coordinates when requesting cell reveal (45ms)
Revealed cell value: 0
    ✔ should allow a player to request cell reveal and check if it's a mine or not (293ms)
    ✔ should prevent revealing a cell in an inactive game
Revealed cell at (0, 0) has value: 0
Revealed cell at (0, 1) has value: 0
Revealed cell at (0, 2) has value: 0
Revealed cell at (0, 3) has value: 0
Revealed cell at (0, 4) has value: 0
Revealed cell at (0, 5) has value: 0
Revealed cell at (0, 6) has value: 0
Revealed cell at (0, 7) has value: 0
Revealed cell at (1, 0) has value: 0
Revealed cell at (1, 1) has value: 0
Revealed cell at (1, 2) has value: 0
Revealed cell at (1, 3) has value: 0
Revealed cell at (1, 4) has value: 0
Revealed cell at (1, 5) has value: 0
Game lost! A mine was revealed.
X:  1 Y:  6
    ✔ should lose the game when a mine is revealed (233ms)


  6 passing (710ms)
```

### Lint Solidity

Lint the Solidity code:

```sh
pnpm lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```sh
pnpm lint:ts
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```sh
pnpm clean
```

### Coverage

#### Test Coverage for FHEMinesweeper.sol:

| File               | Statements | Branches | Functions | Lines  |
| ------------------ | ---------- | -------- | --------- | ------ |
| FHEMinesweeper.sol | 96%        | 78.57%   | 100%      | 94.74% |

To analyze the coverage of the tests, you can use this command:

```bash
pnpm coverage
```

Then open the file `coverage/index.html`. You can see there which line or branch for each contract which has been
covered or missed by your test suite. This allows increased security by pointing out missing branches not covered yet by
the current tests.

## License

This project is licensed under MIT.
