/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require("./tasks/deploy");
require("./tasks/sell");
require("./tasks/buy");

module.exports = {
  solidity: "0.8.17",
  networks: {
    ganache: {
      id:7555,
      url: "http://127.0.0.1:7545",
      accounts: ['f5fb6f09f62a6c6420ddb4551c0ce44b292b9774892a780fcee09a2d2877e3bc', 'a3c458a6ae85cb822504b0afce687a29e65ecb06898546678d3e35ec09c8d3e5']
    }
  }
};
