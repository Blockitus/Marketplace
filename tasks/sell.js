//The address eneed to be changed
const addressFactory = "0x813dedf7Da25ADE4A07B50A088427DFE886721C2";

task("sell", "sell a new NFT")
    .addParam("collection", "collection's address.")
    .addParam("id", "id to sell.")
    .addParam("price", "nft's price.")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BlockitusMarketplace", addressFactory);
        await bmarket.connect(signers[0]).sell(taskArgs.collection, taskArgs.id, taskArgs.price.toString());
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let res = await bmarket.getPrice(taskArgs.collection, taskArgs.id);
        console.log(" price " + res[0]);
})