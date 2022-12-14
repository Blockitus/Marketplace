//The address eneed to be changed
const addressFactory = "0x75A5613D43084CF8A78034c78D736b4e9B75745C";

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
        console.log(" transaction hash " + res.transactionHash);
})