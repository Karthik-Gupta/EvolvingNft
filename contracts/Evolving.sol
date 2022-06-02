// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

interface CharacterInterface {
    function ownerOf(uint256 tokenId)
    external
    view
    returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface AccessoriesInterface {
    function balanceOf(address account, uint256 id)
    external
    view
    returns (uint);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract Evolving is ERC721, Ownable {
    CharacterInterface characterContract;
    AccessoriesInterface accessoriesContract;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    
    struct EvNft{
        uint characterId;
        bool accessory1;
        bool accessory2;
        bool accessory3;
    }
    
    mapping(address => EvNft) public composition;

    /// @dev initialise character and accessory contracts
    constructor(address character, address accessory) ERC721("Evolving", "EVO") {
        characterContract = CharacterInterface(character);
        accessoriesContract = AccessoriesInterface(accessory);
        // start the token count from 1
        _tokenIdCounter.increment();
    }

    /// @dev dynamic character contract set
    function setCharacterContractAddress(address _address) 
        external 
        onlyOwner 
    {
        characterContract = CharacterInterface(_address);
    }

    /// @dev dynamic accessories contract set
    function setAccessoriesContractAddress(address _address) 
        external 
        onlyOwner 
    {
        accessoriesContract = AccessoriesInterface(_address);
    }

    /// can also accept uint[] for accessory input but looping through usually costs more gas
    /// @dev non-payable function for easy simulation
    function evolvedMint(uint characterId, bool accessory1, bool accessory2, bool accessory3) 
        public
        returns (uint)
    {
        EvNft memory evNft = EvNft(0, false, false, false); 
        
        require(characterContract.ownerOf(characterId) == msg.sender, "EvolvedMint: character is not owned");
        evNft.characterId = characterId;
        if (accessory1) {
            require(accessoriesContract.balanceOf(msg.sender, 1) > 0, "EvolvedMint: accessory1 is not owned");
            evNft.accessory1 = true;
        }
        if (accessory2) {
            require(accessoriesContract.balanceOf(msg.sender, 2) > 0, "EvolvedMint: accessory2 is not owned");
            evNft.accessory2 = true;
        }
        if (accessory3) {
            require(accessoriesContract.balanceOf(msg.sender, 3) > 0, "EvolvedMint: accessory3 is not owned");
            evNft.accessory3 = true;
        }

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId, "");
        composition[msg.sender] = evNft;
        return tokenId;
    }

    /// @dev hook implementation to process the base and accessory transfer upon the evolved nft transfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        virtual
        override
    {
        super._beforeTokenTransfer(from, to, tokenId); // Call parent hook
        EvNft memory evNft = composition[from];
        console.log("evNft characterId : %d", evNft.characterId);
        console.log("acc 1: %o , acc 2: %o , acc 3: %o", evNft.accessory1, evNft.accessory2, evNft.accessory3);
        if (!(evNft.characterId == 0 && !evNft.accessory1 && !evNft.accessory2 && !evNft.accessory3))
        {
            console.log(">>> msg.sender: ", msg.sender);
            characterContract.safeTransferFrom(from, to, evNft.characterId);
            console.log("after character transfer");
            if (evNft.accessory1) {
                accessoriesContract.safeTransferFrom(from, to, 1, 1, "");
                console.log("after acc1 transfer");
            }
            if (evNft.accessory2) {
                accessoriesContract.safeTransferFrom(from, to, 2, 1, "");
                console.log("after acc2 transfer");
            }
            if (evNft.accessory3) {
                accessoriesContract.safeTransferFrom(from, to, 3, 1, "");
                console.log("after acc3 transfer");
            }
        }
    }
}