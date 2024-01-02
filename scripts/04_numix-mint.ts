import { ethers, network } from "hardhat";
import { Numix, Numix__factory, NusicClips, NusicClips__factory } from "../typechain-types";
const addresses = require("./address.json");

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  console.log("Network = ",network.name);

  const Numix:Numix__factory = await ethers.getContractFactory("Numix");
  const numix:Numix = await Numix.attach(addresses[network.name].nusicClips);
  await numix.deployed();

  console.log("Numix deployed to:", numix.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
