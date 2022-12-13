/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require("./tasks/deploy");
require("./tasks/sell");
require("./tasks/buy");
require("./tasks/signin");
require("./tasks/approveForAll");
require("./tasks/getBalanceOf");
require("./tasks/getOffer");

module.exports = {
  solidity: "0.8.17",
  networks: {
    ganache: {
      id:7555,
      url: "http://127.0.0.1:7545",
      accounts: ['7f03c48bfbfede45e7f3202329ae9d9628bf6ace7740a61aed8aa3b3b77a55c0', 'ea787c9a845aefae85fb50529f83829b04bfe3d52b4abf49532beebeead36810']
    }
  }
};
