//The address eneed to be changed
const addressFactory = "0x813dedf7Da25ADE4A07B50A088427DFE886721C2";

task("buy", "buy a new NFT")
    .addParam("collection", "collection's address.")
    .addParam("id", "id to sell.")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BlockitusMarketplace", addressFactory);
        await bmarket.connect(signers[1]).buy(taskArgs.collection, taskArgs.id);
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let tx = await bmarket.getPrice(taskArgs.collection, taskArgs.id);
        let res = await tx.wait();
        console.log("Transaction hash " + res.transactionHash);
})