const WhitelistAssets = artifacts.require('StellarCreditCustodian')
const Metadata = artifacts.require('Metadata')
const Credit = artifacts.require('@evrynetlabs/credit-contract/contracts/EER2B.sol')
const BigNumber = require('bignumber.js')
const Contract = require('@truffle/contract')
const ERC165MockData = require('@openzeppelin/contracts/build/ERC165Mock.json')
const Web3 = require('web3')
const truffleAssert = require('truffle-assertions')
const assert = require('chai').assert

const provider = new Web3.providers.HttpProvider('http://localhost:7545')
const mockERC165 = Contract(ERC165MockData)
mockERC165.setProvider(provider)

contract('WhitelistAssets', function (accounts) {
  const accountFoo = accounts[0]
  let fungibleCreditTypeID
  let metadataAddr

  it('should add a new credit', async () => {
    metadataAddr = Metadata.address
    fungibleCreditTypeID = await createCredit(accountFoo, false, metadataAddr)
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.add(fungibleCreditTypeID)
      truffleAssert.eventEmitted(tx, 'AddedAsset')
    } catch (e) {
      assert.fail('should not throw error adding new whitelist credit')
    }
  })

  it('should not add a duplicated credit', async () => {
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.add(fungibleCreditTypeID)
      truffleAssert.eventNotEmitted(tx, 'AddedAsset')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: cannot add the asset that has already been in the whitelist')
    }
  })

  it('should not add a credit with ID zero', async () => {
    const badCreditTypeID = 0
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.add(badCreditTypeID)
      truffleAssert.eventNotEmitted(tx, 'AddedAsset')
      assert.fail('it should throw error adding credit ID zero')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: the credit id cannot be zero')
    }
  })

  it('should report error for adding credit without ERC165 implemented', async () => {
    metadataAddr = '0x0000000000000000000000000000000000000001'
    const badCreitTypeID = await createCredit(accountFoo, false, metadataAddr)
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.add(badCreitTypeID)
      truffleAssert.eventNotEmitted(tx, 'AddedAsset')
      assert.fail('it should throw error adding credit ID without implement metadata interface')
    } catch (e) {
      assert.equal(e.message, 'Returned error: VM Exception while processing transaction: revert')
    }
  })

  it('should report error for adding ERC165 credit with unsupported interface', async () => {
    const instance = await mockERC165.new({ from: accountFoo })
    metadataAddr = instance.address
    const badCreditTypeID = await createCredit(accountFoo, false, metadataAddr)
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.add(badCreditTypeID)
      truffleAssert.eventNotEmitted(tx, 'AddedAsset')
      assert.fail('it should throw error adding credit ID implement ERC165 but without implement metadata interface')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: the metadata contract is not supported interface')
    }
  })

  it('should not remove a credit with ID zero', async () => {
    const badCreditTypeID = 0
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.remove(badCreditTypeID, 0)
      truffleAssert.eventNotEmitted(tx, 'RemovedAsset')
      assert.fail('it should throw error removing credit ID zero')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: the credit id cannot be zero')
    }
  })

  it('should not remove a credit when the information is invalid', async () => {
    metadataAddr = Metadata.address
    const badCreditTypeID = 99
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.remove(badCreditTypeID, badCreditTypeID)
      truffleAssert.eventNotEmitted(tx, 'RemovedAsset')
      assert.fail('it should throw error removing credit with an invalid')
    } catch (e) {
      assert.equal(e.reason, 'WhitelistAssets: invalid remove argument')
    }
  })

  it('should remove an asset', async () => {
    const whitelistAssets = await WhitelistAssets.deployed()
    try {
      const tx = await whitelistAssets.remove(fungibleCreditTypeID, 0)
      truffleAssert.eventEmitted(tx, 'RemovedAsset')
    } catch (e) {
      assert.fail('should not throw error removing asset')
    }
  })

  async function createCredit (src, isNF, metalink) {
    let fungibleCreditTypeID
    credit = await Credit.deployed()
    const tx = await credit.create(metalink, isNF, { from: src })
    truffleAssert.eventEmitted(tx, 'TransferSingle', (ev) => {
      return ev._operator === src
    })
    truffleAssert.eventEmitted(tx, 'URI', (ev) => {
      fungibleCreditTypeID = new BigNumber(ev._typeID)
      return ev._value == metadataAddr
    })
    return fungibleCreditTypeID
  }
})
