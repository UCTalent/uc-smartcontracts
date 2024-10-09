const { ethers, upgrades, network } = require('hardhat')
const { verifyContract } = require('../../utils/auto-verify')

const linkPrefix = `https://${network.config.chainId === 84532 ? 'sepolia.' : ''}basescan.org/address/`

async function main() {
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
