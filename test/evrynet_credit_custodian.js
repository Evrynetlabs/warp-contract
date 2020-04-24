const Credit = artifacts.require('@evrynetlabs/credit-contract/contracts/EER2B.sol')
const EvrynetCreditCustodian = artifacts.require('EvrynetCreditCustodian')
const Metadata = artifacts.require('Metadata')
const truffleAssert = require('truffle-assertions')
const BigNumber = require('bignumber.js')
const assert = require('chai').assert

const amountFoo = 1000000

contract('Evrynet Credit Custodian - unlock ', function (accounts) {
    const accountFoo = accounts[0]
    let evrynetCreditCustodian
    let fungibleCreditTypeID

    before(async () => {
        evrynetCreditCustodian = await EvrynetCreditCustodian.deployed()
        fungibleCreditTypeID = await createCredit(accountFoo, false, evrynetCreditCustodian.address)
    })

    it('should unlock successfully', async () => {
        try {
            truffleAssert.eventEmitted(await evrynetCreditCustodian.add(fungibleCreditTypeID), 'AddedAsset')
            const tx = await evrynetCreditCustodian.unlock(fungibleCreditTypeID, amountFoo, { from: accountFoo })
            truffleAssert.eventEmitted(tx, 'Unlock', (ev) => {
                return ev.to === accountFoo && ev.value == amountFoo && fungibleCreditTypeID.isEqualTo(ev.typeID)
            })
        } catch (e) {
            assert.fail('it should not throw error unlocking credit')
        }
    })

    it('should fail to unlock because the credit is not in the whitelist', async () => {
        const badCreditTypeID = 99
        try {
            const tx = await evrynetCreditCustodian.unlock(badCreditTypeID, amountFoo, { from: accountFoo })
            truffleAssert.eventNotEmitted(tx, 'Unlock')
            assert.fail('it should throw error unlocking non-whitelist credit')
        } catch (e) {
            assert.equal(e.reason, 'WhitelistAssets: the credit is prohibited')
        }
    })
})

contract('Evrynet Credit Custodian - lock', function (accounts) {
    const accountFoo = accounts[0]
    let evrynetCreditCustodian
    let fungibleCreditTypeID

    before(async () => {
        evrynetCreditCustodian = await EvrynetCreditCustodian.deployed()
        fungibleCreditTypeID = await createCredit(accountFoo, false, evrynetCreditCustodian.address)
    })

    it('should lock successfully', async () => {
        try {
            truffleAssert.eventEmitted(await evrynetCreditCustodian.add(fungibleCreditTypeID), 'AddedAsset')
            const unlockTx = await evrynetCreditCustodian.unlock(fungibleCreditTypeID, amountFoo, { from: accountFoo })
            truffleAssert.eventEmitted(unlockTx, 'Unlock', (ev) => {
                return ev.to === accountFoo && ev.value == amountFoo && fungibleCreditTypeID.isEqualTo(ev.typeID)
            })
            const lockTx = await evrynetCreditCustodian.lock(fungibleCreditTypeID, amountFoo, { from: accountFoo })
            truffleAssert.eventEmitted(lockTx, 'Lock', (ev) => {
                return ev.from === accountFoo && ev.value == amountFoo && fungibleCreditTypeID.isEqualTo(ev.typeID)
            })
        } catch (e) {
            assert.fail('it should now throw error locking credit')
        }
    })

    it('should fail to lock because the credit is not in the whitelist', async () => {
        const badCreditTypeID = 99
        try {
            const tx = await evrynetCreditCustodian.lock(badCreditTypeID, amountFoo, { from: accountFoo })
            truffleAssert.eventNotEmitted(tx, 'Lock')
            assert.fail('it should throw error locking non-whitelist credit')
        } catch (e) {
            assert.equal(e.reason, 'WhitelistAssets: the credit is prohibited')
        }
    })
})

async function createCredit(src, isNF, contractAddr) {
    const initialValue = 10000000
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
    const tos = [contractAddr]
    const values = [initialValue]
    credit.mintFungible(fungibleCreditTypeID, tos, values)
    credit.setApprovalForAll(contractAddr, fungibleCreditTypeID)
    return fungibleCreditTypeID
}