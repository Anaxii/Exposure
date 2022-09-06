const Web3 = require("web3")
const HDWalletProvider = require("@truffle/hdwallet-provider")

Web3.providers.HttpProvider.prototype.sendAsync =
  Web3.providers.HttpProvider.prototype.send
const provider = new Web3.providers.HttpProvider(
  `https://api.avax-test.network/ext/bc/C/rpc`
)

const privateKeys = [
  "",
]

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      // gas: 0x1fffffffffffff
    },
    avaxtestnet: {
      provider: () => {
        return new HDWalletProvider({
          privateKeys: privateKeys,
          providerOrUrl: provider,
        })
      },
      network_id: "*",
      gas: 8000000,
      // gasPrice: 225000000000,
    },
  },
  plugins: [
    'truffle-contract-size'
  ],
  compilers: {
    solc: {
      version: "^0.8.0",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1
        }
      }// Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  }
};
