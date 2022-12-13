//The address eneed to be changed
const addressFactory = "0x8B7df01b3ba239CC6cE4DC9a661093Cd3b3917a8";

task("buy", "buy a new NFT")
    .addParam("id", "ofer to buy.")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        let tx = await bmarket.connect(signers[1]).buy(taskArgs.id);
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        
        let res = await tx.wait();
        console.log("Transaction hash " + res.transactionHash);
})