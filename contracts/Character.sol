// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Character is ERC721, Ownable {
    // main evolving nft contract address for approval
    address evContract;
    using Counters for Counters.Counter;

    uint256 public mintPrice = 0.1 ether;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Character", "KAG") {
        // start the token count from 1
        _tokenIdCounter.increment();
    }

    /// @dev dynamic evolving nft contract set
    function setEvolvingContractAddress(address _address) 
        external 
        onlyOwner 
    {
        evContract = _address;
    }

    /// @dev payable function
    function characterPurchase() 
        public
        payable
        returns (uint256)
    {
        require(msg.value >= mintPrice, "CharacterPurchase: incorrect payment");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        return tokenId;
    }

    /// @dev non-payable function for easy simulation
    function characterMint() 
        public
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        approve(evContract, tokenId);
        return tokenId;
    }
}