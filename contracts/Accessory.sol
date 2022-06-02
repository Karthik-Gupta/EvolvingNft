// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Accessory is ERC1155, Ownable {
    // main evolving nft contract address for approval
    address evContract;

    // total supplies of each accessory
    uint16[] supplies = [50, 50, 50];
    // minted supplies tracking
    uint16[] minted = [0, 0, 0];
    // each accesory's price
    uint64[] price = [0.005 ether, 0.008 ether, 0.01 ether];

    constructor() ERC1155("https://metadata.com/tokens/{id}") {}

    /// @dev dynamic evolving nft contract set
    function setEvolvingContractAddress(address _address) 
        external 
        onlyOwner 
    {
        evContract = _address;
    }
    
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /// @dev payable function
    function accessoryPurchase(uint16 id, uint16 amount)
        public
        payable
    {
        require(id <= supplies.length, "AccessoryPurchase: accessory doesn't exist");
        require(id > 0, "AccessoryPurchase: accessory doesn't exist");
        require(minted[id] + amount <= supplies[id], "AccessoryPurchase: max supply reached");
        require(msg.value >= amount * price[id], "AccessoryPurchase: incorrect payment");
        
        _mint(msg.sender, id, amount, "");
        minted[id] += amount;

    }

    /// @dev non-payable function for easy simulation
    function accessoryMint(uint16 id)
        public
    {
        require(id > 0 && id <= supplies.length, "Accessorymint: accessory doesn't exist");
        uint index = id - 1;
        require(minted[index] + 1 <= supplies[index], "AccessoryMint: max supply reached");
        
        _mint(msg.sender, id, 1, "");
        minted[index] += 1;
        // approve nft contract to perform transfer on behalf of owner
        setApprovalForAll(evContract, true);
    }
}
