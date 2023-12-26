import { ethers, network } from "hardhat";
import { Numix, NumixController, NumixController__factory, Numix__factory, NusicClips, NusicClips__factory } from "../typechain-types";

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  console.log("Network = ",network.name);

  const Numix:Numix__factory = await ethers.getContractFactory("Numix");
  const numix:Numix = await Numix.deploy("NToken1","N1");
  await numix.deployed();

  console.log("Numix deployed to:", numix.address);

  const NumixController:NumixController__factory = await ethers.getContractFactory("NumixController");
  const numixController:NumixController = await NumixController.deploy(numix.address);
  await numixController.deployed();

  console.log("NumixController deployed to:", numixController.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
