const { ethers, upgrades } = require('hardhat');
const { verifyContract } = require('../../utils/auto-verify')

async function main() {
  const UCReferral = await ethers.getContractFactory('UCReferral');
  const citizen = await upgrades.upgradeProxy('0x4Cb3D85c7dE6AA8185720955BE89356980FD8b1B', UCReferral);
  await citizen.deployed()
  console.log('UCReferral upgraded');
  await verifyContract(await upgrades.erc1967.getImplementationAddress(citizen.address))
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
