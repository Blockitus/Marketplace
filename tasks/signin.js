//The address eneed to be changed
const addressFactory = "0x8B7df01b3ba239CC6cE4DC9a661093Cd3b3917a8";

task("signIN", "create a new account")
 
    .setAction(async (taskArgs) => {
        const signers = await ethers.getSigners();
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        await bmarket.connect(signers[0]).signIn();
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let res = await bmarket.accountExist(signers[0].address);
        console.log(" price " + res[0]);
})