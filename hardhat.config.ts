import { HardhatUserConfig } from 'hardhat/types';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import 'hardhat-typechain';
import 'hardhat-deploy';
import 'solidity-coverage';
import { config as dotEnvConfig } from 'dotenv';

dotEnvConfig();

const ALCHEMY_HOST_URL = process.env.ALCHEMY_HOST_URL || '';
const MUMBAI_PRIVATE_KEY = process.env.MUMBAI_PRIVATE_KEY || ''; // well known private key
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || '';

const config: HardhatUserConfig = {
	defaultNetwork: 'hardhat',
	solidity: {
		version: '0.8.8',
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	networks: {
		mumbai: {
			url: ALCHEMY_HOST_URL,
			accounts: [MUMBAI_PRIVATE_KEY],
		},
		hardhat: {
			chainId: 31337,
			// gasPrice: 130000000000,
		},
		// coverage: {
		//   url: "http://127.0.0.1:8555",
		// },
	},
	etherscan: {
		apiKey: ETHERSCAN_API_KEY,
	},
	namedAccounts: {
		deployer: {
			default: 0, // here this will by default take the first account as deployer
			1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
		},
	},
	mocha: {
		timeout: 200000, // 200 seconds max for running tests
	},
};

export default config;
