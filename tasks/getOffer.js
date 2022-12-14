//The address eneed to be changed
const addressFactory = "0x98BB60bE0eFDbFAf505f012929d9c6a01C0A881A";

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