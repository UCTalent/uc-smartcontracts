const { ethers, upgrades, network } = require('hardhat')
const { verifyContract } = require('../../utils/auto-verify')

const linkPrefix = `https://${network.config.chainId === 80001 ? 'sepolia.' : ''}basescan.org/address/`

async function main() {
  const UCReferral = await ethers.getContractFactory('UCReferral')
  const ucReferral = await upgrades.deployProxy(UCReferral, ['0x727653b8E67D68a75608CFb205C81758Cc105BcC', '0xe60f7599994989D2eB9D74EB32a58a813CaDB339'])
  await ucReferral.deployed()
  console.log(`UCReferral Proxy contract address: ${linkPrefix}${ucReferral.address}`)
  await verifyContract(await upgrades.erc1967.getImplementationAddress(ucReferral.address))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
