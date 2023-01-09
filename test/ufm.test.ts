import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { assert, expect } from 'chai';
import { network, deployments, ethers } from 'hardhat';
import { BigNumber, utils } from 'ethers';
import { Buffer } from 'buffer';
import { developmentChains, networkConfig } from '../helper-hardhat-config';
import { UltimateFightingMetaverse } from '../typechain';

const mintFee = ethers.utils.parseEther('0.01');

if (developmentChains.includes(network.name)) {
	describe('UltimateFightingMetaverse Unit tests', () => {
		let contract: UltimateFightingMetaverse;
		let player: SignerWithAddress;
		let accounts: SignerWithAddress[];

		beforeEach(async () => {
			[, player] = await ethers.getSigners();
			const contractFactory = await ethers.getContractFactory('UltimateFightingMetaverse');
			contract = (await contractFactory.deploy()) as UltimateFightingMetaverse;
		});

		describe.skip('constructor', async () => {
			it('should have the correct initial values', async () => {});
		});

		describe('mint', async () => {
			it('mints an nft correctly', async () => {});
		});
	});
}
