
task("deploy", "Deploy a Blockitus Marketplace", async () => {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    
    console.log("Account balance:", (await deployer.getBalance()).toString());
    
    const BMarket = await ethers.getContractFactory("BMarket1155");
    const bmarket = await BMarket.deploy();
  
    console.log("BMarket's address is ", bmarket.address);  
  })
  