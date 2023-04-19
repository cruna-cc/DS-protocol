require("dotenv").config();
const hre = require("hardhat");
const ethers = hre.ethers;

const {deployContract, currentChainId, Tx} = require("../test/helpers");

async function main() {
  let [deployer] = await ethers.getSigners();
  const chainId = await currentChainId();
  const network = chainId === 5 ? "goerli" : "localhost";

  console.log("Deploying contracts with the account:", deployer.address, "to", network);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  console.log("Deploying MyToken...");
  const dominant = await deployContract("MyToken");
  console.log("MyToken deployed to:", dominant.address);

  for (let i = 1; i < 3; i++) {
    await Tx(dominant.safeMint(deployer.address, i), "Minting token " + i);
  }

  console.log("Deploying MySubordinate...");
  const subordinate = await deployContract("MySubordinate", dominant.address);
  console.log("MySubordinate deployed to:", subordinate.address);

  await Tx(subordinate.mint(1), "Emit Transfer for #1");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
