import { ethers, network } from "hardhat";
import { NusicClips, NusicClips__factory } from "../typechain-types";

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  console.log("Network = ",network.name);

  const NusicClips:NusicClips__factory = await ethers.getContractFactory("NusicClips");
  const nusicClips:NusicClips = await NusicClips.deploy("MmmCherry - Goddess","GODDESS");
  await nusicClips.deployed();

  console.log("NusicClips deployed to:", nusicClips.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
