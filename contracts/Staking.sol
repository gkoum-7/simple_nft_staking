// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./Camp.sol";

contract Staking {
    Camp public camp;
    IERC721 public dappCampWarriors;

    struct Stake {
        address owner;
        uint256 tokenId;
        uint256 initTimestamp;
    }

    mapping(uint256 => Stake) public staked;

    /**
     * @dev 1 $CAMP per second
     */
    uint256 public rewardPerSecondInWei = 1000000000000000000;

    constructor(address _camp, address _dappCampWarriors) {
        camp = Camp(_camp);
        dappCampWarriors = IERC721(_dappCampWarriors);
    }

    function stake(uint256 tokenId) public {
        /**
         * @dev This prevents 3 things:
         *   - Staking non-existing NFTs (ERC721 ownerOf validates existence)
         *   - Staking if msg.sender is not the owner
         *   - Staking NFTs that are already staked (since the owner is this contract)
         * @notice you need to approve the Staking contract to act on behalf of the tokenId owner
         */
        require(
            dappCampWarriors.ownerOf(tokenId) == msg.sender,
            "Staking: only the owner can stake an NFT"
        );

        dappCampWarriors.transferFrom(msg.sender, address(this), tokenId);

        staked[tokenId] = Stake(msg.sender, tokenId, block.timestamp);
    }

    function unstake(uint256 tokenId) public {
        /**
         * @dev This prevents 3 things:
         *   - Unstaking non-existing NFTs (ERC721 ownerOf validates existence)
         *   - Unstaking if msg.sender is not the owner
         *   - Unstaking NFTs that are not staked (since staked[tokenId].owner will be the zero address)
         */
        require(
            staked[tokenId].owner == msg.sender,
            "Staking: only the owner can unstake an NFT"
        );
        require(
            staked[tokenId].initTimestamp != block.timestamp,
            "Staking: cannot unstake an NFT in the same block it was staked"
        );

        /**
         * @notice Don't use this method to calculate rewards in production.
         * Miners are able to manipulate the block timestamp, so don't rely on it.
         * A possible alternative is using a timestamp oracle.
         */
        uint256 stakedSeconds = block.timestamp - staked[tokenId].initTimestamp;

        delete staked[tokenId];

        dappCampWarriors.transferFrom(address(this), msg.sender, tokenId);
        /**
         * @notice you need to transfer ownership of Camp token to this contract so it can mint 
         */
        camp.mint(msg.sender, stakedSeconds * rewardPerSecondInWei);
    }
}
