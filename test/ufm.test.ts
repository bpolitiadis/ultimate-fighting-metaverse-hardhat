/* eslint-disable no-await-in-loop */
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
			await contract.deployed();
		});

		describe('constructor', async () => {
			it('should have the correct initial values', async () => {
				const maxTokenSupply = await contract.getMaxTokenSupply();
				const mintPrice = await contract.getMintPrice();
				const maxArenas = await contract.getMaxArenas();
				expect(maxTokenSupply.toNumber()).to.equal(maxSupply, 'Max supply is not correct');
				expect(mintPrice.toString()).to.equal(mintFee.toString(), 'Mint price is not correct');
				expect(maxArenas).to.equal(totalArenas, 'Max arenas is not correct');
			});
		});

		describe('mint', async () => {
			it('mints an nft correctly', async () => {
				const response = await contract.safeMint('test', { value: mintFee });
				const receipt = await response.wait();
				const tokenId = receipt.events?.[0].args?.tokenId;

				const tokenURI = await contract.tokenURI(tokenId);
				expect(tokenURI).to.equal('test', 'Token URI is not correct');
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
				};
				// console.log(JSON.stringify(fighterStatsObj));
				expect(fighterStats.strength.toNumber()).to.not.equal(0, 'Strength is 0');
				expect(fighterStats.stamina.toNumber()).to.not.equal(0, 'Stamina is 0');
				expect(fighterStats.technique.toNumber()).to.not.equal(0, 'Technique is 0');
				expect(fighterStats.rarity.toString()).to.be.equal('0' || '1' || '2' || '3', 'Rarity is not 0, 1, 2 or 3');
				expect(fighterStats.victories.toNumber()).to.equal(0, 'Victories is not 0');
			});

			it.skip('mints all nfts', async () => {
				let response;
				let receipt;
				let tokenId;
				let tokenURI;
				// eslint-disable-next-line no-plusplus
				for (let i = 0; i <= maxSupply; i++) {
					response = await contract.safeMint(`test${i.toString()}`, { value: mintFee });
					receipt = await response.wait();
					tokenId = receipt.events?.[0].args?.tokenId;
					tokenURI = await contract.tokenURI(tokenId);
					expect(tokenURI).to.equal(`test${i.toString()}`, 'Token URI is not correct');
				}

				// expect an error when trying to mint more than the max supply of nfts allowed in the contract
				// await expect(contract.safeMint('test', { value: mintFee })).to.be.revertedWith('Max supply reached');
			});

			it('tries to mint an nft with less than mint price and fails', async () => {
				await expect(
					contract.safeMint('test', { value: ethers.utils.parseEther('0.009') })
				).to.be.revertedWith('Mint price not met');
			});

			it('tries to mint an nft with empty url and fails', async () => {
				await expect(contract.safeMint('', { value: mintFee })).to.be.revertedWith(
					'Token URI cannot be empty'
				);
			});
		});

		describe('joinArena', async () => {
			it('joins the arena correctly', async () => {
				let response; let receipt;

				// mint two fighters
				response = await contract.safeMint('test1', { value: mintFee });
				receipt = await response.wait();
				const tokenId1 = receipt.events?.[0].args?.tokenId;

				response = await contract.safeMint('test2', { value: mintFee });
				receipt = await response.wait();
				const tokenId2 = receipt.events?.[0].args?.tokenId;

				// join arena
				response = await contract.joinArena(1, tokenId1);
				receipt = await response.wait();
				const arenaId = receipt.events?.[0].args?.arenaId;
				console.log(arenaId.toString());

				// check arena
				const arena = await contract.getArena(1);
				expect(arena.tokenId1.toString()).to.equal(tokenId1.toString());
				console.log(arena.toString());


				response = await contract.joinArena(1, tokenId2);
				receipt = await response.wait();

				// check arena


			});
		});
	});
}
