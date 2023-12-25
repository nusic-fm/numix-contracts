import { ethers, network } from "hardhat";
import { NusicClips, NusicClips__factory } from "../typechain-types";
const addresses = require("./address.json");

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  console.log("Network = ",network.name);

  const NusicClips:NusicClips__factory = await ethers.getContractFactory("NusicClips");
  const nusicClips:NusicClips = await NusicClips.attach(addresses[network.name].nusicClips);

  console.log("NusicClips Address:", nusicClips.address);

  const txt = await nusicClips.mint("1","https://bafybeifq35avyqny5kjrifwmiyf5zwqapzkxepgwpgyszlwuoqpcawnvye.ipfs.w3s.link/test-metadata.json");
  console.log("txt.hash = ",txt.hash);
  const receipt = await txt.wait();
  console.log("receipt = ",receipt);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
