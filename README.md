# Minesweeper FHE

A Fully Homomorphic Encryption (FHE) powered Minesweeper game built on [fhEVM](https://github.com/zama-ai/fhevm) using
Solidity. The game board remains encrypted on-chain, allowing players to reveal cells without exposing the full state.
This project demonstrates the use of FHE for privacy-preserving gameplay in smart contracts.

## Template

This project was build using the [fhevm-hardhat-template](https://github.com/zama-ai/fhevm-hardhat-template/generate)

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
