//The address eneed to be changed
const addressFactory = "0x8B7df01b3ba239CC6cE4DC9a661093Cd3b3917a8";

task("getOffer", "get NFT's characteristics")
    .addParam("id", "id to sell.")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let res = await bmarket.getOffer(taskArgs.id);
        console.log(" seller " + res[0]);
        console.log(" collection " + res[1]);
        console.log(" nftId " + res[2]);
        console.log(" price " + res[3]);
})