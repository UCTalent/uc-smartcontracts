const { ethers, network } = require('hardhat')
const { verifyContract } = require('../utils/auto-verify')
const { timeout } = require('../utils/async')

async function main() {
  let linkPrefix = 'https://bscscan.com/address/'
  if (network.config.chainId === 97) {
    linkPrefix = 'https://testnet.bscscan.com/address/'
  } else if (network.config.chainId === 84532) {
    linkPrefix = 'https://sepolia.basescan.org/address/'
  } else if (network.config.chainId === 8453) {
    linkPrefix = 'https://basescan.org/address/'
  }
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
