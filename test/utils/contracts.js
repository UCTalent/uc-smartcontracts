const { ethers, upgrades } = require('hardhat')
const EIP712_NAME = 'UCTalent'
const EIP712_VERSION = '1'


async function loadContractFactory(name) {
  return ethers.getContractFactory(name)
}

async function loadContractAt(name, address) {
  return ethers.getContractAt(name, address)
}

async function initUCReferralContract() {
  const usdtToken = await initMockTokenInstance('MUSDTToken')
  const jobNFT = await initJobNFTContract()
  const UCReferral = await ethers.getContractFactory('UCReferral')
  const ucReferral = await upgrades.deployProxy(UCReferral, [EIP712_NAME, EIP712_VERSION, usdtToken.address, jobNFT.address])
  await ucReferral.deployed()
  await jobNFT.updateMintAble(ucReferral.address, true)
  return ucReferral
}

async function fundToken(tokenInstance, user, amount) {
  await tokenInstance.transfer(user, amount)
}

async function initJobNFTContract() {
  const JobNFT = await ethers.getContractFactory('JobNFT')
  const jobNFT = await upgrades.deployProxy(JobNFT, ['JobNFT', 'JNFT'])
  await jobNFT.deployed()
  return jobNFT
}

async function initMockTokenInstance(contractName) {
  const Contract = await ethers.getContractFactory(contractName)
  const contract = await Contract.deploy()

  await contract.deployed()
  const accounts = await ethers.getSigners()
  await contract.mint(accounts[0].address, '100000000000000')
  return contract
}

module.exports = {
  fundToken,
  loadContractFactory,
  loadContractAt,
  initUCReferralContract
}
