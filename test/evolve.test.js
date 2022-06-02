const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Evolving NFT", function () {
  let character;
  let accessory;
  let evolving;
  let owner;
  let addr1;
  let addr2;
  before(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();

    const Character = await ethers.getContractFactory("Character");
    character = await Character.deploy();
    await character.deployed();
    const Accessory = await ethers.getContractFactory("Accessory");
    accessory = await Accessory.deploy();
    await accessory.deployed();
    const Evolving = await ethers.getContractFactory("Evolving");
    evolving = await Evolving.deploy(character.address, accessory.address);
    await evolving.deployed();

    await character.setEvolvingContractAddress(evolving.address);
    await accessory.setEvolvingContractAddress(evolving.address);
  });

  describe("Working with Character", function () {
    it("Mint character token 1", async () => {
      await character.connect(addr1).characterMint();
    });
    it("Verify owner of character token 1", async () => {
      expect(addr1.address).to.equal(await character.ownerOf(1));
    });
  });

  describe("Working with Accessory", function () {
    it("Mint accessories 1,2,3", async () => {
      await accessory.connect(addr1).accessoryMint(1);
      await accessory.connect(addr1).accessoryMint(2);
      await accessory.connect(addr1).accessoryMint(3);
    });
    it("Verify accessory balance", async () => {
      expect(1).to.equal(await accessory.balanceOf(addr1.address, 1));
      expect(1).to.equal(await accessory.balanceOf(addr1.address, 2));
      expect(1).to.equal(await accessory.balanceOf(addr1.address, 3));
    });
  });

  describe("Working with Evolved NFT", function () {
    it("Mint evolve token 1", async () => {
      await evolving.connect(addr1).evolvedMint(1, false, true, false);
    });
    it("Verify owner of evolve token 1", async () => {
      expect(addr1.address).to.equal(await evolving.ownerOf(1));
    });
    it("Transfer evolved token", async () => {
      await evolving
        .connect(addr1)
        ["safeTransferFrom(address,address,uint256)"](
          addr1.address,
          addr2.address,
          1
        );
    });
    it("Verify evolved token and its base and accessory", async () => {
      expect(addr2.address).to.equal(await evolving.ownerOf(1));
      expect(addr2.address).to.equal(await character.ownerOf(1));
      // accessory 1 is not equipped and hence not transferred to addr2
      expect(1).to.not.equal(await accessory.balanceOf(addr2.address, 1));
      // accessory 2 is equipped and hence transferred to addr2 along with evolved nft
      expect(1).to.equal(await accessory.balanceOf(addr2.address, 2));
      // accessory 3 is not equipped and hence not transferred to addr2
      expect(1).to.not.equal(await accessory.balanceOf(addr2.address, 3));
    });
  });
});
