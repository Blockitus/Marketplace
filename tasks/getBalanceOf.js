//The address eneed to be changed
const addressFactory = "0x98BB60bE0eFDbFAf505f012929d9c6a01C0A881A";

task("getBalance", "return user's balance")
    .addParam("user", "user's address.")
    .setAction(async (taskArgs) => {
        const bmarket = await ethers.getContractAt("BMarket1155", addressFactory);
        //let token_address = await erc20Factory.decodeFunctionResult("createToken", tx.data);
        let res = await bmarket.balanceOf(taskArgs.user, 1);
        console.log(" balance of " + taskArgs.user + " is " +res);
})