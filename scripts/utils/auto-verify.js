const { run, hardhatArguments } = require('hardhat')
const { whitelistNetworkDeploy } = require('../../hardhat.config')

async function verifyContract(address, args = []) {
  if (!address) {
    throw new Error('Empty address!')
  }

  const { network } = hardhatArguments
  let verifyScript

  if (address) {
    verifyScript = `npx hardhat verify ${address} ${network ? `--network ${network}` : ''}`
    console.log(`Run this script to Verify contract: ${verifyScript}`)
  }

  if (whitelistNetworkDeploy.includes(network) && address) {
    console.log('****** Auto run verify contract ******')

    if (Array.isArray(args) && args.length) {
      await run('verify:verify', {
        address,
        constructorArguments: args
      })
    } else {
      await run('verify:verify', { address })
    }
  }
}

module.exports = {
  verifyContract
}
