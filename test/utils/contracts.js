const { ethers, upgrades } = require('hardhat')

async function initContractInstance() {
  const Contract = await loadContractFactory('Token')
  const contract = await Contract.deploy('Token', 'TKT')
  await contract.deployed()
  return contract
}

async function initContractInstanceUpgrade() {
  const Contract = await loadContractFactory('Foo')
  const contract = await upgrades.deployProxy(Contract, [])
  await contract.deployed()
  return contract
}

async function loadContractFactory(name) {
  return ethers.getContractFactory(name)
}

async function loadContractAt(name, address) {
  return ethers.getContractAt(name, address)
}

module.exports = {
  loadContractFactory,
  loadContractAt,
  initContractInstance,
}
