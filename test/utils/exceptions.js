const { expect } = require('chai')

async function tryCatch(promise, reason) {
  return expect(promise).to.be.revertedWith(reason)
}

async function catchEvent(promise, contract, eventName, args = []) {
  if (args.length) {
    return expect(promise).to
      .emit(contract, eventName)
      .withArgs(...args)
  }

  return expect(promise).to
    .emit(contract, eventName)
}

module.exports = {
  async catchRevert(promise) { await tryCatch(promise, 'revert') },
  async catchRevertWithReason(promise, reason) { await tryCatch(promise, reason) },
  async catchOutOfGas(promise) { await tryCatch(promise, 'out of gas') },
  async catchInvalidJump(promise) { await tryCatch(promise, 'invalid JUMP') },
  async catchInvalidOpcode(promise) { await tryCatch(promise, 'invalid opcode') },
  async catchStackOverflow(promise) { await tryCatch(promise, 'stack overflow') },
  async catchStackUnderflow(promise) { await tryCatch(promise, 'stack underflow') },
  async catchStaticStateChange(promise) { await tryCatch(promise, 'static state change') },
  async catchEvent(promise, contract, eventName, args = []) {
    await catchEvent(promise, contract, eventName, args)
  },
}
