//The address eneed to be changed
const addressFactory = "0x75A5613D43084CF8A78034c78D736b4e9B75745C";

task("approve", "approve for all NFT owned by an user")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        let tx =await bmarket.connect(signers[0]).setApprovalForAll(addressFactory, true);
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
    
        let res = await tx.wait();
        console.log("Transaction hash " + res.transactionHash);
})