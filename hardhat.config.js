require('@nomicfoundation/hardhat-toolbox')
require('@openzeppelin/hardhat-upgrades')
require('@nomiclabs/hardhat-web3')
require('hardhat-contract-sizer')
require('dotenv').config()

const { BSC_ETHER_SCAN, UNTALENT_TEST_NET: testnetPrivateKey, PRIVATE_KEY_MAIN_NET: mainnetPrivateKey, BASE_SEPOLIA } = process.env
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  whitelistNetworkDeploy: ['bscTestnet', 'baseTestnet'],
  networks: {
    bscTestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      accounts: [testnetPrivateKey],
      chainId: 97,
    },
    bscMainnet: {
      url: 'https://sparkling-virulent-panorama.bsc.quiknode.pro/4b01fdce7b5fd547b98447ab226d07d11d96f66f/',
      accounts: [mainnetPrivateKey],
      chainId: 56,
    },
    baseMainnet: {
      url: 'https://api.basescan.org/api',
      accounts: [mainnetPrivateKey],
      chainId: 8453
    },
    baseTestnet: {
      url: 'https://snowy-flashy-darkness.base-sepolia.quiknode.pro/1ab0968e86bdb4b640d6943c362aeac4974c8c79/',
      accounts: [testnetPrivateKey],
      chainId: 84532
    },
    cotiTestnet: {
      url: 'https://testnet.coti.io/rpc',
      accounts: [testnetPrivateKey],
      chainId: 7082400,
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: 'USD'
  },
  etherscan: {
    apiKey: {
      bsc: BSC_ETHER_SCAN,
      bscTestnet: BSC_ETHER_SCAN,
      baseSepolia: BASE_SEPOLIA
    },
    customChains: [
      {
        network: 'base',
        chainId: 8453,
        urls: {
          apiURL: 'https://api.basescan.org/api',
          browserURL: 'https://basescan.org'
        }
      },
      {
        network: 'baseSepolia',
        chainId: 84532,
        urls: {
          apiURL: 'https://api-sepolia.basescan.org/api',
          browserURL: 'https://sepolia.basescan.org'
        }
      }
    ]
  }
};
