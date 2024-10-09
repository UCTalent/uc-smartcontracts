const { ethers } = require('hardhat')
const { BigNumber } = ethers

const value1String = '1000000000000000000'
const value1BN = BigNumber.from(value1String)
const value3String = '3000000000000000000'
const value3BN = BigNumber.from(value3String)
const value10String = '10000000000000000000'
const value10BN = BigNumber.from(value10String)
const value2String = '2000000000000000000'
const value2BN = BigNumber.from(value2String)
const value175String = '175000000000000000000'
const value175BN = BigNumber.from(value175String)
const value420MString = '420000000000000000000000000'
const value420MBN = BigNumber.from(value420MString)
const value100String = '100000000000000000000'
const value100BN = BigNumber.from(value100String)
const value500String = '500000000000000000000'
const value500BN = BigNumber.from(value500String)
const value1000String = '1000000000000000000000'
const value1000BN = BigNumber.from(value1000String)
const value5000String = '5000000000000000000000'
const value5000BN = BigNumber.from(value5000String)

module.exports = {
  BigNumber,
  value1String,
  value1BN,
  value10BN,
  value2BN,
  value3BN,
  value100BN,
  value175BN,
  value420MBN,
  value500BN,
  value500String,
  value1000BN,
  value1000String,
  value5000BN,
  value5000String
}
