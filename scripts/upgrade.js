const { parseEther } = require("ethers/lib/utils");

async function deploy_MyNFTV2(){

  console.log("Deploying MyNFTV2");
  console.log("------------------------------------------------------");
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MyNFTV2 = await ethers.getContractFactory("MyNFTV2");
  const mynftv2 = await upgrades.upgradeProxy("0x8991926CEAa46C1b0427a6d9cFb7d18E588D611e", MyNFTV2);
  await mynftv2.deployed();

  console.log("[MyNFTV2] address:", mynftv2.address);

}
deploy_MyNFTV2().then().catch();