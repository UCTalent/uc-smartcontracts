const { ethers, upgrades, network } = require('hardhat')
const { verifyContract } = require('../../utils/auto-verify')

const linkPrefix = `https://${network.config.chainId === 80001 ? 'testnet.' : ''}bscscan.com/address/`

async function main() {
  const UCReferral = await ethers.getContractFactory('UCReferral')
  const ucReferral = await upgrades.deployProxy(UCReferral)
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
