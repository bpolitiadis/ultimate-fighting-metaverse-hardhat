import { DeployFunction } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { developmentChains, VERIFICATION_BLOCK_CONFIRMATIONS } from '../helper-hardhat-config';
import verify from '../utils/verify';

const deployUltimateFightingMetaverse: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const { deployments, getNamedAccounts, network, ethers } = hre;
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const waitBlockConfirmations = developmentChains.includes(network.name)
		? 1
		: VERIFICATION_BLOCK_CONFIRMATIONS;

	log('----------------------------------------------------');

	// const args: unknown[] = [];
	const contract = await deploy('UltimateFightingMetaverse', {
		from: deployer,
		// args,
		log: true,
		waitConfirmations: waitBlockConfirmations || 1,
	});

	// Verify the deployment
	if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
		log('Verifying...');
		await verify(contract.address, []);
	}
};

export default deployUltimateFightingMetaverse;

deployUltimateFightingMetaverse.tags = ['all', 'main'];
