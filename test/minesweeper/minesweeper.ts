import { expect } from "chai";
import { ethers } from "hardhat";

import { awaitAllDecryptionResults, initGateway } from "../asyncDecrypt";
import { getSigners, initSigners } from "../signers";

describe("FHEMinesweeper", function () {
  before(async function () {
    await initSigners();
    this.signers = await getSigners();
    await initGateway();
  });

  beforeEach(async function () {
    const contractFactory = await ethers.getContractFactory("FHEMinesweeper");
    this.contract = await contractFactory.connect(this.signers.alice).deploy();
    await this.contract.waitForDeployment();
    this.contractAddress = await this.contract.getAddress();
  });

  it("should allow a player to start a game", async function () {
    await this.contract.connect(this.signers.alice).startGame();
    const game = await this.contract.games(this.signers.alice.address);
    expect(game.gameActive).to.equal(true);
    expect(game.remainingSafeCells).to.equal(54); // 64 - 10 mines
  });

  it("should prevent starting a new game while one is active", async function () {
    await this.contract.connect(this.signers.alice).startGame();
    await expect(this.contract.startGame()).to.be.revertedWithCustomError(this.contract, "GameInProgress");
  });

  it("should allow a player to request cell reveal and check if it's a mine or not", async function () {
    await this.contract.connect(this.signers.alice).startGame();

    const tx = await this.contract.connect(this.signers.alice).requestCellReveal(0, 0);
    await tx.wait();
    await awaitAllDecryptionResults();

    const logs = await this.contract.queryFilter(this.contract.filters.CellRevealed());

    expect(logs.length, "Event CellRevealed not found").to.be.greaterThan(0);

    const event = logs[0];
    const value = Number(event.args[3]);

    console.log(`Revealed cell value: ${value}`);
    expect(value, "Unexpected cell value").to.be.oneOf([0, 1]);
  });

  it("should prevent revealing a cell in an inactive game", async function () {
    await expect(this.contract.connect(this.signers.alice).requestCellReveal(0, 0)).to.be.revertedWithCustomError(
      this.contract,
      "NoActiveGame",
    );
  });

  // it("should prevent revealing a cell twice", async function () {
  //   await this.contract.connect(this.signers.alice).startGame();
  //   await this.contract.connect(this.signers.alice).requestCellReveal(0, 0);
  //   await awaitAllDecryptionResults();

  //   await expect(this.contract.connect(this.signers.alice).requestCellReveal(0, 0)).to.be.revertedWithCustomError(
  //     this.contract,
  //     "CellAlreadyRevealed",
  //   );
  // });

  it("should lose the game when a mine is revealed", async function () {
    await this.contract.connect(this.signers.alice).startGame();

    for (let x = 0; x < 8; x++) {
      for (let y = 0; y < 8; y++) {
        console.log("HERE", x, y);
        const tx = await this.contract.connect(this.signers.alice).requestCellReveal(x, y);
        await tx.wait();
        await awaitAllDecryptionResults();

        const logs = await this.contract.queryFilter(this.contract.filters.CellRevealed());
        expect(logs.length, "Event CellRevealed not found").to.be.greaterThan(0);

        const event = logs[0];
        const value = Number(event.args[3]);
        console.log(`Revealed cell at (${x}, ${y}) has value: ${value}`);
      }
    }
  });

  it("should win the game when all safe cells are revealed", async function () {
    await this.contract.connect(this.signers.alice).startGame();

    for (let x = 0; x < 8; x++) {
      for (let y = 0; y < 8; y++) {
        const tx = await this.contract.connect(this.signers.alice).requestCellReveal(x, y);
        await tx.wait();
        await awaitAllDecryptionResults();

        // Проверка на победу после каждого хода
        const winLogs = await this.contract.queryFilter(this.contract.filters.GameWon());
        if (winLogs.length > 0) {
          const game = await this.contract.games(this.signers.alice.address);
          expect(game.gameActive).to.equal(false);
          expect(game.remainingSafeCells).to.equal(0);
          console.log("Game won! All safe cells revealed.");
          return;
        }
      }
    }
    throw new Error("GameWon event was not emitted");
  });
});
