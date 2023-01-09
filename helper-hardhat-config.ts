export interface NetworkConfigItem {
	name?: string;
	subscriptionId?: string;
	callbackGasLimit?: string;
	vrfCoordinatorV2?: string;
	gasLane?: string;
	mintFee?: string;
}

export interface NetworkConfigInfo {
	[key: number]: NetworkConfigItem;
}

export const networkConfig: NetworkConfigInfo = {
	31337: {
		name: 'localhost',
		gasLane: '0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc', // 30 gwei
		mintFee: '10000000000000000', // 0.01 ETH
		callbackGasLimit: '500000', // 500,000 gas
	},
	// Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
	// Default one is ETH/USD contract on Kovan
	80001: {
		name: 'mumbai',
		vrfCoordinatorV2: '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255',
		gasLane: '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4',
		callbackGasLimit: '500000', // 500,000 gas
		mintFee: '10000000000000000', // 0.01 MATIC
		subscriptionId: '1002', // add your ID here! VRF
	},
};

export const DECIMALS = '18';
export const INITIAL_PRICE = '200000000000000000000';
export const developmentChains = ['hardhat', 'localhost'];
export const VERIFICATION_BLOCK_CONFIRMATIONS = 6;
