import 'dotenv/config';
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-gas-reporter';
import './utils/wellknown';
import '@openzeppelin/hardhat-upgrades';
import '@nomiclabs/hardhat-etherscan';
import {node_url, accounts} from './utils/networks';

const SCAN_API_KEY = '5TG3YFQN115DW1J6636C8XR7QJ8DPWYSSE';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.4',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      accounts: accounts('localhost'),
    },
    localhost: {
      url: 'http://localhost:8545',
      accounts: accounts('localhost'),
    },
    harmony: {
      url: 'https://api.harmony.one',
      chainId: 1666600000,
      accounts: accounts('harmony'),
      live: true,
    },
    moonriver: {
      url: 'https://rpc.moonriver.moonbeam.network',
      chainId: 1285,
      accounts: accounts('moonriver'),
      live: true,
    },
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 5,
    enabled: !!process.env.REPORT_GAS,
  },
  namedAccounts: {
    creator: 9,
    deployer: 9,
  },
  etherscan: {
    apiKey: SCAN_API_KEY,
  },
};

export default config;
