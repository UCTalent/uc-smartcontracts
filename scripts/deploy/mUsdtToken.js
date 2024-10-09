const { ethers, network } = require('hardhat')
const { verifyContract } = require('../utils/auto-verify')
const { timeout } = require('../utils/async')

const linkPrefix = `https://${network.config.chainId === 80001 ? 'sepolia.' : ''}basescan.org/address/`

async function main() {
  const MUSDTToken = await ethers.getContractFactory('MUSDTToken')
  const token = await MUSDTToken.deploy()
  console.log(`MUSDTToken Proxy contract address: ${linkPrefix}${token.address}`)
  await timeout(20000)
  await verifyContract(token.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
