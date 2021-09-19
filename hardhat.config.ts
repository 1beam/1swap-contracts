import 'dotenv/config';
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-gas-reporter';
import '@openzeppelin/hardhat-upgrades';
import '@nomiclabs/hardhat-etherscan';

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
    localhost: {
      url: 'http://localhost:8545',
    },
    moonriver: {
      url: 'https://rpc.moonriver.moonbeam.network',
      chainId: 1285,
      live: true,
    },
  },
};

export default config;
