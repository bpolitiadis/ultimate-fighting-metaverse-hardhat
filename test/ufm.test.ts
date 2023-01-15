import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { assert, expect } from 'chai';
import { network, deployments, ethers } from 'hardhat';
import { BigNumber, utils } from 'ethers';
import { developmentChains, networkConfig } from '../helper-hardhat-config';
import { UltimateFightingMetaverse } from '../typechain';

const maxSupply = 1000;
const mintFee = ethers.utils.parseEther('0.01');
const totalArenas = 8;

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

		describe('constructor', async () => {
			it('should have the correct initial values', async () => {
				const maxTokenSupply = await contract.getMaxTokenSupply();
				const mintPrice = await contract.getMintPrice();
				const maxArenas = await contract.getMaxArenas();
				expect(maxTokenSupply.toNumber()).to.equal(maxSupply);
				expect(mintPrice.toString()).to.equal(mintFee.toString());
				expect(maxArenas).to.equal(totalArenas);
			});
		});

		describe('mint', async () => {
			it('mints an nft correctly', async () => {
				const response = await contract.safeMint('test', { value: mintFee });
				const receipt = await response.wait();
				const tokenId = receipt.events?.[0].args?.tokenId;

				const tokenURI = await contract.tokenURI(tokenId);
				expect(tokenURI).to.equal('test');
				// const owner = await contract.ownerOf(tokenId);
				// expect(owner).to.equal(player.address);
				// const balance = await contract.balanceOf(player.address);
				// expect(balance.toNumber()).to.equal(1);
				const fighterStats = await contract.getFighterStats(tokenId);
				const fighterStatsObj = {
					strength: fighterStats.strength.toNumber(),
					stamina: fighterStats.stamina.toNumber(),
					technique: fighterStats.technique.toNumber(),
					rarity: fighterStats.rarity.toString(),
					victories: fighterStats.victories.toNumber(),
				}
				console.log(JSON.stringify(fighterStatsObj));
				expect(fighterStats.strength.toNumber()).to.not.equal(0);
				expect(fighterStats.stamina.toNumber()).to.not.equal(0);
				expect(fighterStats.technique.toNumber()).to.not.equal(0);
				expect(fighterStats.rarity.toString()).to.be.equal("0" || "1" || "2" || "3");
				expect(fighterStats.victories.toNumber()).to.equal(0);

			});
		});

		describe('joinArena', async () => {
			it('joins the arena correctly', async () => {});
		});
	});
}
