const { ethers } = require('hardhat')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bn')(ethers.BigNumber))
  .should()

function to(promise) {
  return promise.then((data) => {
    return [null, data]
  }).catch((error) => {
    console.log('error form to func:', error)
    try {
      return [JSON.parse(error.message)]
    } catch (e) {
      return [error]
    }
  })
}

let accountsMap = {}

async function getAccounts() {
  const accounts = await ethers.getSigners()
  if (!accountsMap.mainAdmin) {
    accountsMap = {
      ...accountsMap,
      zeroAddress: '0x0000000000000000000000000000000000000000',
      mainAdmin: accounts[0],
      mainAdminAddress: accounts[0].address,
      contractAdmin: accounts[accounts.length - 1],
      liquidityPool: accounts[0]
    }

    for (let i = 1; i < accounts.length - 10; i += 1) {
      accountsMap[`user${i}`] = accounts[i]
      accountsMap[`user${i}Address`] = accounts[i].address
    }
  }
  return accountsMap
}

function getTokenIdFromResponse(response, index = 0) {
  return response.receipt.logs[index].args.tokenId
}

module.exports = {
  getAccounts,
  accountsMap,
  getTokenIdFromResponse,
  to
}
