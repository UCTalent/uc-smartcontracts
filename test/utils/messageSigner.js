const { ecsign, privateToAddress } = require('ethereumjs-util')
const { getMessage } = require('eip-712')

const EIP712_NAME = 'NAME'
const EIP712_VERSION = '1'
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' }
]

const BuySaleDatas = [
  { name: 'user', type: 'address' },
  { name: 'allocated', type: 'uint256' },
  { name: 'price', type: 'uint256' }
]

function signMessageBuyPrivateSale(verifyingContract, message, chainId = 1) {
  const typedData = {
    types: {
      EIP712Domain,
      Buy: BuySaleDatas
    },
    primaryType: 'Buy',
    domain: {
      name: EIP712_NAME,
      version: EIP712_VERSION,
      chainId,
      verifyingContract
    },
    message
  };
  const privateKey = Buffer.from(process.env.PRIVATE_KEY_ADMIN_FOR_TEST, 'hex')

  const messageFromData = getMessage(typedData, true)
  const { r, s, v } = ecsign(messageFromData, privateKey)
  return `0x${r.toString('hex')}${s.toString('hex')}${v.toString(16)}`
}

function getAddressFromPrivateKey(key) {
  // eslint-disable-next-line no-buffer-constructor
  const account = privateToAddress(new Buffer(key, 'hex'))
  return `0x${account.toString('hex')}`
}

module.exports = {
  getAddressFromPrivateKey,
  signMessageBuyPrivateSale,
  EIP712_NAME,
  EIP712_VERSION
}
