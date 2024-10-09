const { ethers } = require('hardhat')
const { expect } = require('chai')
const createInstance = require('../utils/contracts')
const { getAccounts } = require('../utils')
const { value1BN } = require('../utils/dataHolder')
const { catchRevertWithReason, catchEvent } = require('../utils/exceptions')

let tokenContract
let accounts

describe('Token', async () => {
  before(async () => {
    accounts = await getAccounts()
  })

  beforeEach(async () => {
    tokenContract = await createInstance.initContractInstance()
  })

  it('Should deployed', async () => {
    const [tokenName, symbol, owner] = await Promise.all([
      tokenContract.name(),
      tokenContract.symbol(),
      tokenContract.owner()
    ])

    tokenName.should.equal('Token')
    symbol.should.equal('TKT')
    owner.should.equal(accounts.mainAdminAddress)
  })

  it('Should mint token', async () => {
    const amount = value1BN
    await tokenContract.mint(accounts.mainAdminAddress, amount)
    const adminBalance = await tokenContract.balanceOf(accounts.mainAdminAddress)

    expect(adminBalance).to.equal(amount)
  })

  it('Should burn token', async () => {
    const amount = value1BN
    await tokenContract.mint(accounts.mainAdminAddress, amount)
    const adminBalanceBefore = await tokenContract.balanceOf(accounts.mainAdminAddress)
    const totalSupplyBefore = await tokenContract.totalSupply()
    await tokenContract.burn(accounts.mainAdminAddress, amount)
    const adminBalanceAfter = await tokenContract.balanceOf(accounts.mainAdminAddress)
    const totalSupplyAfter = await tokenContract.totalSupply()

    expect(adminBalanceAfter).to.equal(adminBalanceBefore.sub(amount))
    expect(totalSupplyAfter).to.equal(totalSupplyBefore.sub(amount))
  })

  it('Should block user', async () => {
    const status = true
    const response = await tokenContract.blockUser(accounts.user1Address, status)
    const blockUser = await tokenContract.blockUsers(accounts.user1Address)

    await catchEvent(response, tokenContract, 'BlockedUser', [
      accounts.mainAdminAddress,
      accounts.user1Address,
      status
    ])

    expect(blockUser).to.equal(status)
  })

  it('Should return error: Token: user address invalid - when block zero address', async () => {
    const status = true
    await catchRevertWithReason(
      tokenContract.blockUser(ethers.constants.AddressZero, status),
      'Token: user address invalid!'
    )
  })
})
