const Credit = artifacts.require('@Evrynetlabs/credit-contract/contracts/EER2B.sol')
const StellarCreditCustodian = artifacts.require('StellarCreditCustodian')
const Metadata = artifacts.require('Metadata')
const truffleAssert = require('truffle-assertions')
const BigNumber = require('bignumber.js')
const assert = require('chai').assert

let credit

contract('Stellar Credut Custodian - migrate vote', function (accounts) {
  const accountFoo = accounts[0]
  let addressFoo
  let stellarCreditCustodian

  before(async () => {
    stellarCreditCustodian = await StellarCreditCustodian.deployed()
    const newStellarCreditCustodian = await StellarCreditCustodian.new(Credit.address, 1)
    addressFoo = newStellarCreditCustodian.address
  })

  it('should migrate the contract', async () => {
    try {
      const tx = await stellarCreditCustodian.migrationVote(addressFoo, { from: accountFoo })
      truffleAssert.eventEmitted(tx, 'Migrate', (ev) => {
        return ev.to === addressFoo
      })
    } catch (e) {
      assert.fail('it should not throw error migrating contract')
    }
  })

  it('should fail to make a duplicate migration vote', async () => {
    try {
      await stellarCreditCustodian.migrationVote(addressFoo, { from: accountFoo })
      assert.fail('it should throw error make a duplicated proposal')
    } catch (e) {
      assert.equal(e.reason, 'Migration: Sender has already made a proposal')
    }
  })
})

contract('Stellar Credit Custodian - unlock', function (accounts) {
  const accountFoo = accounts[0]
  const amountFoo = 10000000
  let stellarCreditCustodian
  let fungibleCreditTypeID

  before(async () => {
    stellarCreditCustodian = await StellarCreditCustodian.deployed()
    fungibleCreditTypeID = await createCredit(accountFoo, false, stellarCreditCustodian.address)
  })

  it('should unlock successfully', async () => {
    try {
      truffleAssert.eventEmitted(await stellarCreditCustodian.add(fungibleCreditTypeID), 'AddedAsset')
      const tx = await stellarCreditCustodian.unlock(fungibleCreditTypeID, amountFoo, { from: accountFoo })
      truffleAssert.eventEmitted(tx, 'Unlock', (ev) => {
        return ev.to === accountFoo &&
                    ev.value == amountFoo &&
                    fungibleCreditTypeID.isEqualTo(ev.typeID)
      })
    } catch (e) {
      assert.fail('it should not throw error unlocking credit')
    }
  })

  it('should fail to unlock because the credit is not in the whitelist', async () => {
    const badCreditTypeID = 99
    try {
      const tx = await stellarCreditCustodian.unlock(badCreditTypeID, amountFoo, { from: accountFoo })
      truffleAssert.eventNotEmitted(tx, 'Unlock')
      assert.fail('it should throw error unlocking non-whitelist credit')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: the credit is prohibited')
    }
  })
})

contract('Stellar Credit Custodian - lock', function (accounts) {
  const accountFoo = accounts[0]
  const amountFoo = 10000000
  let stellarCreditCustodian
  let fungibleCreditTypeID

  before(async () => {
    stellarCreditCustodian = await StellarCreditCustodian.deployed()
    fungibleCreditTypeID = await createCredit(accountFoo, false, stellarCreditCustodian.address)
    credit.setApprovalForAll(stellarCreditCustodian.address, true, { from: accountFoo })
  })

  it('should lock successfully', async () => {
    try {
      truffleAssert.eventEmitted(await stellarCreditCustodian.add(fungibleCreditTypeID), 'AddedAsset')
      const unlockTx = await stellarCreditCustodian.unlock(fungibleCreditTypeID, amountFoo, { from: accountFoo })
      truffleAssert.eventEmitted(unlockTx, 'Unlock', (ev) => {
        return ev.to === accountFoo &&
                    ev.value == amountFoo &&
                    fungibleCreditTypeID.isEqualTo(ev.typeID)
      })
      const lockTx = await stellarCreditCustodian.lock(fungibleCreditTypeID, amountFoo, { from: accountFoo })
      truffleAssert.eventEmitted(lockTx, 'Lock', (ev) => {
        return ev.from === accountFoo &&
                    ev.value == amountFoo &&
                    fungibleCreditTypeID.isEqualTo(ev.typeID)
      })
    } catch (e) {
      assert.fail('it should not throw error unlocking credit')
    }
  })

  it('should fail to lock because the credit is not in the whitelist', async () => {
    const badCreditTypeID = 99
    try {
      const tx = await stellarCreditCustodian.lock(badCreditTypeID, amountFoo, { from: accountFoo })
      truffleAssert.eventNotEmitted(tx, 'Lock')
      assert.fail('it should throw error locking non-whitelist credit')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: the credit is prohibited')
    }
  })
})

async function createCredit (src, isNF, contractAddr) {
  let fungibleCreditTypeID
  credit = await Credit.deployed()
  const tx = await credit.create(Metadata.address, isNF, { from: src })
  truffleAssert.eventEmitted(tx, 'TransferSingle', (ev) => {
    return ev._operator === src
  })
  truffleAssert.eventEmitted(tx, 'URI', (ev) => {
    fungibleCreditTypeID = new BigNumber(ev._typeID)
    return ev._value === Metadata.address
  })
  credit.setMinter(fungibleCreditTypeID, contractAddr)
  return fungibleCreditTypeID
}
