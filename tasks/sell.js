//The address eneed to be changed
const addressFactory = "0x8B7df01b3ba239CC6cE4DC9a661093Cd3b3917a8";

task("sell", "sell a new NFT")
    .addParam("collection", "collection's address.")
    .addParam("nftid", "id to sell.")
    .addParam("price", "nft's price.")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        let tx = await bmarket.connect(signers[0]).sell(taskArgs.collection, taskArgs.nftid, taskArgs.price.toString());
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let res = await tx.wait();
        console.log(" price " + res.transactionHash);
})