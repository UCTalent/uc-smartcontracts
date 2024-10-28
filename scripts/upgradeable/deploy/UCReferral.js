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
  const UCReferral = await ethers.getContractFactory('UCReferral')
  // baseTestnet
  // const usdtAddress = '0x727653b8E67D68a75608CFb205C81758Cc105BcC'
  // const jobNFTAddress = '0xe60f7599994989D2eB9D74EB32a58a813CaDB339'
  // cotiTestnet
  const usdtAddress = '0x9927BBBfa9111F8608392F34Cb32A95F59f9fa55'
  const jobNFTAddress = '0xd30F87a3d99d78850d99402B456541964Bdac49a'
  const ucReferral = await upgrades.deployProxy(UCReferral, ['UCTalent', '1', usdtAddress, jobNFTAddress, '0x7E74afd7a2a065f51c1E599B299B8e8B7DA3Bf47'])
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
