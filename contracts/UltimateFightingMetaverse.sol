// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract UltimateFightingMetaverse is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    // |-----------------------------------------------|
    // |---------------Type Declarations---------------|
    // |-----------------------------------------------|

    // Enum representing different rarities of fighters
    enum Rarities {
        Common,
        Uncommon,
        Rare,
        Legendary
    }

    // Struct representing the stats of a fighter
    struct Stats {
        uint256 strength;
        uint256 stamina;
        uint256 technique;
        Rarities rarity;
        uint256 victories;
    }

    // //Struct representing an arena
    // struct Arena {
    //     uint8 arenaId;
    //     uint256 tokenId1;
    //     uint256 tokenId2;
    // }

    // Struct representing a match
    struct Match {
        uint256 matchId;
        uint256 tokenId1;
        uint256 tokenId2;
        uint256 winnerId;
    }

    // Struct representing trait adjustments based on rarity
    struct TraitAdjustmentByRarity {
        uint8 low;
        uint8 high;
    }

    // |-----------------------------------------------|
    // |-----------------State Variables---------------|
    // |-----------------------------------------------|

    // The current token ID for creating new fighters
    Counters.Counter private s_tokenIdCounter;
    // The maximum number of NFT fighters that can be created
    uint256 private immutable i_maxTokenIds = 1000;
    // The mint price to create a new NFT fighter
    uint256 private s_mintPrice = 0.01 * 1000000000000000000;

    // Mapping from bytes to trait adjustments by rarity
    mapping(bytes => TraitAdjustmentByRarity) s_rarityAdjustments;
    // Mapping from token ID to stats for a specific fighter
    mapping(uint256 => Stats) s_tokenIdToStats;

    // Counter for the number of matches that have been created
    Counters.Counter private s_matchIdCounter;
    // Arena entrance fee
    uint256 private s_arenaEntranceFee = 0.01 * 1000000000000000000;
    // The maximum number of arenas that can be created
    uint256 private immutable i_maxArenas = 8;
    // Mapping from arenaID to arena
    mapping(uint8 => Match) private s_arenas; //TODO make private
    // Mapping from matchId to a match
    mapping(uint256 => Match) private s_matches; //TODO make private

    // |-----------------------------------------------|
    // |-----------------Event Emitters----------------|
    // |-----------------------------------------------|

    // Event emitted when a new fighter is created (tokenID is the tokenId of the fighter created and stats are the stats of the fighter)
    event FighterCreated(uint256 tokenId, Stats stats);
    // Event emitted when a match is created (matchId is the matchId of the match created, tokenId1 is the tokenId of the first fighter, tokenId2 is the tokenId of the second fighter, and outcome is the tokenId of the winner)
    event MatchCreated(uint256 matchId, uint256 tokenId1, uint256 tokenId2, uint256 outcome);
    // Event emitted when a arena is created (arenaId is the arenaId of the arena created and tokenId is the tokenId of the fighter in the arena)
    event ArenaOpened(uint256 arenaId, uint256 tokenId);
    // Event emitted when a arena is updated (arenaId is the arenaId of the arena updated and tokenId is the tokenId of the fighter in the arena)
    event ArenaClosed(uint256 arenaId, uint256 matchId);

    // |-----------------------------------------------|
    // |-----------------Modifiers---------------------|
    // |-----------------------------------------------|

    // Modifier to check if the token ID is valid
    modifier isValidTokenId(uint256 tokenId) {
        require(tokenId > 0 && tokenId <= i_maxTokenIds, "Token ID is invalid");
        _;
    }

    // Modifier to check if the match ID is valid
    modifier isValidMatchId(uint256 matchId) {
        require(matchId > 0 && matchId <= s_matchIdCounter.current(), "Match ID is invalid");
        _;
    }

    // Modifier to check if the arena ID is valid
    modifier isValidArenaId(uint256 arenaId) {
        require(arenaId > 0 && arenaId <= i_maxArenas, "Arena ID is invalid");
        _;
    }

    // Modifier to check if the sender is the owner of the token
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
        _;
    }

    // |-----------------Constructor-------------------|
    constructor() ERC721("Ultimate Fighting Metaverse", "UFM") {
        init();
    }

    // |-----------------  Functions ------------------|

    /*
     * Initializes the base stats for each fighter class and rarity adjustments for each rarity level.
     * These values are used to calculate the final stats for a fighter when it is created.
     */
    function init() internal {
        // Store the rarity adjustments in the s_rarityAdjustments mapping
        s_rarityAdjustments[abi.encode(Rarities.Common)] = TraitAdjustmentByRarity(0, 50);
        s_rarityAdjustments[abi.encode(Rarities.Uncommon)] = TraitAdjustmentByRarity(50, 100);
        s_rarityAdjustments[abi.encode(Rarities.Rare)] = TraitAdjustmentByRarity(80, 120);
        s_rarityAdjustments[abi.encode(Rarities.Legendary)] = TraitAdjustmentByRarity(100, 170);
    }

    /**
     * @dev Creates a new non-fungible token and assigns it to the caller.
     * Reverts if the correct amount of ether is not sent with the transaction, if the maximum number of tokens has
     * already been reached, or if there is an error during the minting process.
     * @param _tokenURI The URI of the token.
     */
    function safeMint(string memory _tokenURI) public payable {
        // Ensure that the correct amount of ether has been sent with the transaction
        require(msg.value >= s_mintPrice, "Mint price not met");
        // Ensure that the maximum number of NFTs has not been reached
        uint256 currentCounter = s_tokenIdCounter.current();
        require(currentCounter <= i_maxTokenIds, "Max supply reached");
        require(bytes(_tokenURI).length > 0, "Token URI cannot be empty");

        // Increment the token ID counter and mint the NFT
        s_tokenIdCounter.increment();
        uint256 tokenId = s_tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        // Determine the rarity of the token and generate random strength, stamina, and technique values within the
        // appropriate range for that rarity
        s_tokenIdToStats[tokenId].rarity = getRarity();
        uint256[] memory rand = getRandomNumbers(
            getAdjustmentByRarity(s_tokenIdToStats[tokenId].rarity).low,
            getAdjustmentByRarity(s_tokenIdToStats[tokenId].rarity).high,
            3
        );
        s_tokenIdToStats[tokenId].strength = 80 + rand[0];
        s_tokenIdToStats[tokenId].stamina = 80 + rand[1];
        s_tokenIdToStats[tokenId].technique = 80 + rand[2];

        // Initialize the number of victories to 0
        s_tokenIdToStats[tokenId].victories = 0;

        // Emit a `FighterCreated` event
        emit FighterCreated(tokenId, s_tokenIdToStats[tokenId]);
    }

    /**
     * @dev Allows the owner of a token to join a arena with another player's token. If the arena is full, a match will be
     * initiated between the two tokens and the winner will be stored in the winnerId field of the Match struct.
     * Reverts if the caller is not the owner of the token, if the arena number is invalid, if the token ID is invalid,
     * or if the arena is already full.
     * @param _arenaNumber The number of the arena to join.
     * @param _tokenId The ID of the token to use in the match.
     */
    function joinArena(
        uint8 _arenaNumber,
        uint256 _tokenId
    ) public payable isValidTokenId(_tokenId) isValidArenaId(_arenaNumber) onlyOwnerOf(_tokenId) {
        require(msg.value >= s_arenaEntranceFee);

        // If the first token slot in the arena is empty, store the given token in that slot
        if (s_arenas[_arenaNumber].tokenId1 == 0) {
            s_arenas[_arenaNumber].tokenId1 = _tokenId;
            emit ArenaOpened(_arenaNumber, _tokenId);
            return;
        }

        // If the second token slot in the arena is empty, store the given token in that slot
        if (s_arenas[_arenaNumber].tokenId2 == 0) {
            // If the caller is already in the arena, throw an error
            if (s_arenas[_arenaNumber].tokenId1 == _tokenId) {
                revert("You have joined in this arena already.");
            }
            s_arenas[_arenaNumber].tokenId2 = _tokenId;
        } else {
            // If both slots are full, throw an error
            revert("Arena is full!");
        }

        // Determine the winner of the match between the two tokens
        uint256 outcome = fight(s_arenas[_arenaNumber].tokenId1, s_arenas[_arenaNumber].tokenId2);
        s_arenas[_arenaNumber].winnerId = outcome;

        //Increase the number of victories for the winner
        s_tokenIdToStats[outcome].victories++;

        //Increase the stats of winner
        s_tokenIdToStats[outcome].strength += 3;
        s_tokenIdToStats[outcome].stamina += 3;
        s_tokenIdToStats[outcome].technique += 3;

        // Increase the stats of the loser
        if (s_arenas[_arenaNumber].tokenId1 == outcome) {
            s_tokenIdToStats[s_arenas[_arenaNumber].tokenId2].strength += 1;
            s_tokenIdToStats[s_arenas[_arenaNumber].tokenId2].stamina += 1;
            s_tokenIdToStats[s_arenas[_arenaNumber].tokenId2].technique += 1;
        } else {
            s_tokenIdToStats[s_arenas[_arenaNumber].tokenId1].strength += 1;
            s_tokenIdToStats[s_arenas[_arenaNumber].tokenId1].stamina += 1;
            s_tokenIdToStats[s_arenas[_arenaNumber].tokenId1].technique += 1;
        }

        // Store the match in the `s_matches` mapping and emit a `MatchCreated` event
        s_matchIdCounter.increment();
        s_matches[s_matchIdCounter.current()] = s_arenas[_arenaNumber];
        emit MatchCreated(
            s_matchIdCounter.current(),
            s_arenas[_arenaNumber].tokenId1,
            s_arenas[_arenaNumber].tokenId2,
            outcome
        );

        // Clear the arena and emit a `ArenaClosed` event
        s_arenas[_arenaNumber] = Match(0, 0, 0, 0);
        emit ArenaClosed(_arenaNumber, s_matchIdCounter.current());

        // Transfer the prize to the winner
        payable(ownerOf(outcome)).transfer((s_arenaEntranceFee * 2 * 90) / 100);
    }

    /**
     * Determines the winner of a fight between two fighters.
     *
     * @param _fighter1 The first fighter.
     * @param _fighter2 The second fighter.
     * @return The winning fighter.
     */
    function fight(uint256 _fighter1, uint256 _fighter2) private view returns (uint256) {
        // Calculate the total strength of fighter 1
        uint256 fighter1Sum = s_tokenIdToStats[_fighter1].strength +
            s_tokenIdToStats[_fighter1].stamina +
            s_tokenIdToStats[_fighter1].technique +
            getRandomNumbers(0, 100, 1)[0];

        // Calculate the total strength of fighter 2
        uint256 fighter2Sum = s_tokenIdToStats[_fighter2].strength +
            s_tokenIdToStats[_fighter2].stamina +
            s_tokenIdToStats[_fighter2].technique +
            getRandomNumbers(0, 100, 1)[0];

        uint256 winner;
        // Determine the winner based on the total strength
        if (fighter1Sum >= fighter2Sum) winner = _fighter1;
        else winner = _fighter2;

        return winner;
    }

    /**
     * @dev Determines the rarity of a trait using a pseudo-random number.
     * @return The rarity of the trait, as a value of the Rarities enum.
     */
    function getRarity() private view returns (Rarities) {
        // Generate a pseudo-random number using keccak256 and the blockhash as a seed, and ensure it is at most 10000
        uint256 rand = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1)))) % 10000;

        // Use the pseudo-random number to determine the rarity
        if (rand <= 5000) {
            return Rarities.Common;
        } else if (rand > 5000 && rand <= 8500) {
            return Rarities.Uncommon;
        } else if (rand > 8500 && rand <= 9500) {
            return Rarities.Rare;
        } else {
            return Rarities.Legendary;
        }
    }

    /**
     * @dev Generates an array of pseudo-random numbers within a given range.
     * @param _min The minimum value of the range (inclusive).
     * @param _max The maximum value of the range (inclusive).
     * @param _count The number of random numbers to generate.
     * @return An array of pseudo-random numbers within the specified range.
     */
    function getRandomNumbers(uint256 _min, uint256 _max, uint256 _count) private view returns (uint256[] memory) {
        // Create an array to store the random numbers
        uint256[] memory randomNumbers = new uint256[](_count);

        // Generate the random numbers
        for (uint256 i = 0; i < _count; i++) {
            // Generate a pseudo-random number using keccak256 and the blockhash as a seed
            uint256 rand = (uint256(keccak256(abi.encodePacked(blockhash(block.number - (i))))) % (_max - _min + 1)) + _min;

            // Store the random number in the array
            randomNumbers[i] = rand;
        }

        // Return the array of random numbers
        return randomNumbers;
    }

    /**
     * @dev Returns the TraitAdjustmentByRarity associated with the given rarity.
     * @param rarity The rarity for which to retrieve the TraitAdjustmentByRarity.
     * @return The TraitAdjustmentByRarity associated with the given rarity.
     */
    function getAdjustmentByRarity(Rarities rarity) internal view returns (TraitAdjustmentByRarity memory) {
        if (rarity == Rarities.Common) return s_rarityAdjustments[abi.encode(Rarities.Common)];
        if (rarity == Rarities.Uncommon) return s_rarityAdjustments[abi.encode(Rarities.Uncommon)];
        if (rarity == Rarities.Rare) return s_rarityAdjustments[abi.encode(Rarities.Rare)];
        if (rarity == Rarities.Legendary) return s_rarityAdjustments[abi.encode(Rarities.Legendary)];
        revert("Invalid rarity!");
    }

    // Returns the stats for a fighter
    function getFighterStats(uint256 tokenId) public view isValidTokenId(tokenId) returns (Stats memory) {
        return s_tokenIdToStats[tokenId];
    }

    // Returns last token ID to be minted
    function getLastTokenId() public view returns (uint256) {
        return s_tokenIdCounter.current();
    }

    // Returns max token supply
    function getMaxTokenSupply() public pure returns (uint256) {
        return i_maxTokenIds;
    }

    // Returns the price to mint a new fighter
    function getMintPrice() public view returns (uint256) {
        return s_mintPrice;
    }

    // Returns the arena entrance fee
    function getArenaEntranceFee() public view returns (uint256) {
        return s_arenaEntranceFee;
    }

    // Sets the price to mint a new fighter
    function setMintPrice(uint256 _newPrice) public onlyOwner {
        s_mintPrice = _newPrice;
    }

    // Sets the arena entrance fee
    function setArenaEntranceFee(uint256 _newFee) public onlyOwner {
        s_arenaEntranceFee = _newFee;
    }

    // Returns max number of arenas
    function getMaxArenas() public pure returns (uint256) {
        return i_maxArenas;
    }

    // Returns arena struct for an arenaID
    function getArena(uint8 _arenaId) public view isValidArenaId(_arenaId) returns (Match memory) {
        return s_arenas[_arenaId];
    }

    // Returns all arenas
    function getAllArenas() public view returns (Match[] memory) {
        Match[] memory arenas = new Match[](i_maxArenas);
        for (uint8 i = 0; i < i_maxArenas; i++) {
            arenas[i] = s_arenas[i + 1];
        }
        return arenas;
    }

    // Returns current number of history matches
    function getNumMatches() public view returns (uint256) {
        return s_matchIdCounter.current();
    }

    // Returns the Match struct for a matchID
    function getMatch(uint256 _matchId) public view isValidMatchId(_matchId) returns (Match memory) {
        return s_matches[_matchId];
    }

    // returns all matches
    function getAllMatches() public view returns (Match[] memory) {
        Match[] memory matches = new Match[](s_matchIdCounter.current());
        for (uint256 i = 0; i < s_matchIdCounter.current(); i++) {
            matches[i] = s_matches[i + 1];
        }
        return matches;
    }

    // Returns the fighter's owner
    function getOwner(uint256 tokenId) public view isValidTokenId(tokenId) returns (address) {
        return ownerOf(tokenId);
    }

    // Returns all tokens owned by an address
    function getTokensOwnedByAddress(address _owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 resultIndex = 0;

            for (uint256 i = 1; i <= s_tokenIdCounter.current(); i++) {
                if (ownerOf(i) == _owner) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }

    //Withdraw funds from contract
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
