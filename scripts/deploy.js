const { parseEther } = require("ethers/lib/utils");

async function deploy_BankDefi(){

  console.log("Deploying BankDeFi");
  console.log("------------------------------------------------------");
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const BankDefi = await ethers.getContractFactory("MyContract");
  const bankdefi = await await upgrades.deployProxy(BankDefi, { kind: "uups" });
  await bankdefi.deployed();

  console.log("[BankDefi] address:", bankdefi.address);

}
deploy_BankDefi().then().catch();