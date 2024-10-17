const { ecsign, privateToAddress } = require('ethereumjs-util')
const { getMessage } = require('eip-712')

const EIP712_NAME = 'UCTalent'
const EIP712_VERSION = '1'
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' }
]

const CloseJobDatas = [
  { name: 'jobId', type: 'bytes32' },
  { name: 'success', type: 'bool' },
  { name: 'talent', type: 'address' },
  { name: 'referrer', type: 'address' },
  { name: 'refPercentage', type: 'uint256' },
  { name: 'applyTimestamp', type: 'uint256' },
  { name: 'refTimestamp', type: 'uint256' },
  { name: 'nonce', type: 'uint256' }
]

function signMessageCloseJob(admin, verifyingContract, message, chainId = 31337) {
  const typedData = {
    types: {
      EIP712Domain,
      CloseJob: CloseJobDatas
    },
    primaryType: 'CloseJob',
    domain: {
      name: EIP712_NAME,
      version: EIP712_VERSION,
      chainId,
      verifyingContract
    },
    message
  };
  const privateKey = Buffer.from(admin, 'hex')

  const messageFromData = getMessage(typedData, true)
  const { r, s, v } = ecsign(messageFromData, privateKey)
  return `0x${r.toString('hex')}${s.toString('hex')}${v.toString(16)}`
}

function getAddressFromPrivateKey(key) {
  // eslint-disable-next-line no-buffer-constructor
  const account = privateToAddress(new Buffer.from(key, 'hex'))
  return `0x${account.toString('hex')}`
}

module.exports = {
  getAddressFromPrivateKey,
  signMessageCloseJob,
  EIP712_NAME,
  EIP712_VERSION
}
