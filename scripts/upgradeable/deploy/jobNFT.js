const { ethers, upgrades, network } = require('hardhat')
const { verifyContract } = require('../../utils/auto-verify')

async function main() {
  let linkPrefix = 'https://bscscan.com/address/'
  if (network.config.chainId === 97) {
    linkPrefix = 'https://testnet.bscscan.com/address/'
  } else if (network.config.chainId === 84532) {
    linkPrefix = 'https://sepolia.basescan.org/address/'
  } else if (network.config.chainId === 8453) {
    linkPrefix = 'https://basescan.org/address/'
  }
  const JobNFT = await ethers.getContractFactory('JobNFT')
  const jobNFT = await upgrades.deployProxy(JobNFT, ['JobNFT', 'JNFT'])
  await jobNFT.deployed()
  console.log(`JobNFT Proxy contract address: ${linkPrefix}${jobNFT.address}`)
  await verifyContract(await upgrades.erc1967.getImplementationAddress(jobNFT.address))
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
