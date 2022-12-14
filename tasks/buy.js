

//The address eneed to be changed
const addressFactory = "0x75A5613D43084CF8A78034c78D736b4e9B75745C";

task("buy", "buy a new NFT")
    .addParam("id", "offer to buy.")
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        let gas  = await bmarket.estimateGas.buy(taskArgs.id); 
        //let tx = await bmarket.connect(signers[1]).buy(taskArgs.id, {value: ethers.utils.parseEther("20")});
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        
        //let res = await tx.wait();
        //console.log("Transaction hash " + tx.transactionHash);
        console.log(gas);
    })