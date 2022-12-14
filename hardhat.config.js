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
      accounts: ['468a06f7dc7aba8a279277070640ea80e00a111393adf592f7db7749badb5c82', 'bfae1f9e632c7af7eaec1501c16e77b13100c2ffa514621bad34bdc868edfd00']
    }
  }
};
