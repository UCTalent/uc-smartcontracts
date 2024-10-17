const { expect } = require('chai')
const { ethers } = require('hardhat')
const contractUtils = require('./utils/contracts')
const { getAccounts } = require('./utils')
const messageSigner = require('./utils/messageSigner')
const ethers2 = require('ethers');

let accounts
let ucReferral

describe('UCReferral', async () => {
  beforeEach(async () => {
    accounts = await getAccounts()
    ucReferral = await contractUtils.initUCReferralContract()
  })

  it('should create a job with valid parameters', async () => {
    const user = accounts.user1
    await createJob(user, true)
  })
  it('should close job successfully', async () => {
    const user = accounts.user1
    const talent = accounts.user2Address
    const referrer = accounts.user3Address
    const jobId = await createJob(user)
    const refPercentage = 50
    const refTimestamp = Math.floor(Date.now() / 1000)
    const applyTimestamp = Math.floor(Date.now() / 1000)
    const nonce = await ucReferral.nonce(user.address)
    const message = messageSigner.signMessageCloseJob(accounts.mainAdminKey, ucReferral.address, {
      jobId,
      success: true,
      talent,
      referrer,
      refPercentage,
      applyTimestamp,
      refTimestamp,
      nonce: nonce.toNumber()
    })

    await ucReferral.connect(user).closeJob(jobId, true, talent, referrer, refPercentage, applyTimestamp, refTimestamp, message)
  })
})

async function createJob(user, test = false) {
  const jobIdString = 'foo'
  const jobId = ethers.utils.formatBytes32String(jobIdString)
  const amount = '100000000'
  const timestamp = Math.floor(Date.now() / 1000)
  const usdtToken = await contractUtils.loadContractAt('MUSDTToken', ucReferral.usdtToken())
  await contractUtils.fundToken(usdtToken, user.address, amount)
  await usdtToken.connect(user).approve(ucReferral.address, amount)
  const createJobTx = await ucReferral.connect(user).createJob(jobId, amount, timestamp)
  await createJobTx.wait()
  if (test) {
    const job = await ucReferral.jobs(jobId)
    expect(job.amount).to.equal(amount)
    expect(job.timestamp).to.equal(timestamp)
    const jobNFT = await contractUtils.loadContractAt('JobNFT', ucReferral.jobNFT())
    const nftOwner = await jobNFT.ownerOf(job.nftId)
    expect(nftOwner).to.equal(job.creator)
  }
  return jobId
}
