# UltimateFightingMetaverse

Welcome to UltimateFightingMetaverse, the NFT game where players can mint their own unique fighters and battle it out in the metaverse arenas. With artwork produced by OpenAI's DALL-E and user input from our frontend NextJS application, each fighter is truly one of a kind.

Rarity for each fighter is randomly assigned, with the following odds: Common (50%), Uncommon (35%), Rare (10%), Legendary (5%). The maximum number of fighters that can be minted is 1000. As players fight with their NFTs, they can increase their stats and rise through the ranks to become the ultimate metaverse champion.

## Installation

To install and run UltimateFightingMetaverse, you will need to have [Yarn](https://yarnpkg.com/) installed on your machine.

First, clone the repository:

```
git clone https://github.com/bpolitiadis/ultimate-fighting-metaverse-hardhat.git
```


Next, navigate to the project directory and install the dependencies:

```
cd UltimateFightingMetaverse
yarn install
```

## Deployment

To deploy UltimateFightingMetaverse to the blockchain, you will need to have [Hardhat](https://hardhat.org/) and an Ethereum wallet with some test Ether installed.

First, compile and clean the project:

```
yarn build

```

Next, deploy the contracts to the desired network:

```
yarn hardhat deploy --network [NETWORK]

```

Replace `[NETWORK]` with the desired network (e.g. `rinkeby` or `mainnet`).

## Running Tests

To run the test suite for UltimateFightingMetaverse, use the following command:

```
yarn test
```

This will run all of the Solidity tests for the smart contracts.

## Frontend

To use the frontend application for UltimateFightingMetaverse, visit the following GitHub repository:

https://github.com/[YOUR_USERNAME]/UltimateFightingMetaverse-frontend

Follow the installation instructions in the README to get the application up and running.

## Contributing

We welcome contributions to UltimateFightingMetaverse! If you have an idea for a new feature or have found a bug, please open an issue on GitHub.

## License

UltimateFightingMetaverse is licensed under the [MIT License](LICENSE).
