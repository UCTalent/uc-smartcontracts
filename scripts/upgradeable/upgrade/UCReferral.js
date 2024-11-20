const { ethers, upgrades } = require('hardhat');
const { verifyContract } = require('../../utils/auto-verify')

async function main() {
  const UCReferral = await ethers.getContractFactory('UCReferral');
  const citizen = await upgrades.upgradeProxy('0xEBf5f7D87eeb3C0575a88513e38a701E4d70Bc49', UCReferral);
  await citizen.deployed()
  console.log('UCReferral upgraded');
  await verifyContract(await upgrades.erc1967.getImplementationAddress(citizen.address))
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
