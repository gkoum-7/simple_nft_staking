// deployed on L2 (e.g. optimistic-kovan). When you run the script remember --network optimistic-kovan

const { ethers } = require("hardhat");

async function main() {
    Controller = await ethers.getContractFactory("DappCampWarriors");
    warriorsContract = await Controller.deploy();
    console.log("contract deployed on '%s'", warriorsContract.address)
    /**
     * @dev to view the first NFT on opensea visit
     * https://testnets.opensea.io/assets/{warriorsContract.address}/0
     */
   
}
main()