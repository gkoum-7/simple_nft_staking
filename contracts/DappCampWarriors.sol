// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev We're inheriting from two of the contracts we imported before,
 * a lot of Solidity's reusability happens via inheritance.
 * ERC721 receives two hardcoded params, which its constructor will receive as arguments.
 * Note that the params can be dynamic too, you can see an example here: https://solidity-by-example.org/constructor/.
 * Ownable doesn't receive any param, after extending it our contract is able to use the `onlyOwner` modifier, among others.
 */
contract DappCampWarriors is ERC721("Warriors", "DWAR"), Ownable {
    /**
     * @dev It's not all about inheritance, we can also compose functionality by `using` a library.
     * Read more about the `using` directive: https://docs.soliditylang.org/en/v0.8.13/contracts.html#using-for.
     */
    using Counters for Counters.Counter;

    /**
     * @dev There's 3 things to note in this line of code:
     *      1) We're using a custom data type which we defined on top.
     *      2) We're using the `internal` keyword.
     *      3) We're prefixing the variable with an underscore, because it's internal.
     * Read more about `internal`: https://docs.soliditylang.org/en/v0.8.13/contracts.html#state-variable-visibility.
     * Notice that the underscore convention for internal variables and functions is not in Solidity's style guide,
     * but it's a widely used convention and OpenZeppelin's contracts use it.
     * Read the Solidity style guide here: https://docs.soliditylang.org/en/v0.8.13/style-guide.html.
     */
    Counters.Counter internal _tokenIds;

    /**
     * @dev baseURI is the URI that's used to construct the URL in which the metadata of the NFT is hosted.
     * Making it `public` provides us with a getter that makes reading it more convenient.
     */
    string public baseURI;

    /**
     * @dev The constructor method is executed once, on contract deployment.
     * It's important to have in mind that all the constructors of the inherited contracts will be executed too,
     * in this case Ownable and ERC721.
     * I recommend you reading the constructors of the contracts you inherit,
     * you'll note, for example, that Ownable sets the deployer as the initial owner.
     */
    constructor() {
        /**
         * @dev First we need to set the URI. For this example we will be using BAYC's URI (this is hardcoded in the constructor).
         * The owner can change the base URI, and have the NFTs minted thereafter point somewhere else. 
         * Then we mint 10 NFTs owned by the contract deployer. Later, the owner can mint more NFTs as he pleases, 
         * and sent them to the address he wants to (see `mint(address to)` function).
         * To view the first NFT on opensea visit https://testnets.opensea.io/assets/{warriorsContract.address}/0 .
         * NOTE: if owner changes the baseURI at some point in the future, then the NFTs minted thereafter will point 
         * to other locations/images.
         */
 

        setBaseURI("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
        for (uint256 i = 0; i < 10; i++) {
            mint(msg.sender);
        }
    }

    /**
     * @dev Overriding a function from OpenZeppelin's ERC-721.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev Note that the onlyOwner modifier is being used, otherwise anyone could change the baseURI of our collection.
     */
    function setBaseURI(string memory _baseURIParam) public onlyOwner {
        baseURI = _baseURIParam;
    }

    /**
     * @dev We decided that only the owner of the contract will be able to mint, this is an arbitrary decision,
     * other NFT collections may allow anyone (virtually unlimited supply) or no-one (scarce NFT collection) to mint.
     */
    function mint(address to) public onlyOwner returns (uint256) {
        uint256 newWarriorId = _tokenIds.current();
        _safeMint(to, newWarriorId);

        _tokenIds.increment();

        return newWarriorId;
    }
}