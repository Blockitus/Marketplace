//The address eneed to be changed
const addressFactory = "0x8B7df01b3ba239CC6cE4DC9a661093Cd3b3917a8";

task("getBalance", "return user's balance")
    .addParam("user", "user's address.")
    .setAction(async (taskArgs) => {
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let res = await bmarket.balanceOf(taskArgs.user, 1);
        console.log(" seller " + res);
})