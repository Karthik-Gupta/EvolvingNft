// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Character = await hre.ethers.getContractFactory("Character");
  const character = await Character.deploy();
  await character.deployed();
  console.log("Character deployed to:", character.address);

  const Accessory = await hre.ethers.getContractFactory("Accessory");
  const accessory = await Accessory.deploy();
  await accessory.deployed();
  console.log("Accessory deployed to:", accessory.address);

  const Evolving = await hre.ethers.getContractFactory("Evolving");
  const evolving = await Evolving.deploy(character.address, accessory.address);
  await evolving.deployed();
  console.log("Evolving deployed to:", evolving.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
