const NativeAssetCustodian = artifacts.require('NativeAssetCustodian')
const truffleAssert = require('truffle-assertions')
const assert = require('chai').assert

contract('Native Asset Custodian - lock', function (accounts) {
    it('should be able to lock the native asset', async () => {
        const custodian = await NativeAssetCustodian.deployed()
        const accountFoo = accounts[1]
        const amountFoo = '1000000000'
        try {
            const tx = await custodian.lock({from: accountFoo, value: amountFoo})
            truffleAssert.eventEmitted(tx, 'LockNative', (ev) => {
                return ev.owner === accountFoo && ev.value.toString() === amountFoo
            })
        } catch (e) {
            assert.fail('it should not throw error locking native asset')
        }
    })
})

contract('Native Asset Custodian - unlock', function (accounts) {
    it('should be able to unlock the native asset', async () => {
        const custodian = await NativeAssetCustodian.deployed()
        const baseAccount = accounts[0]
        const amountFoo = '1000000000'
        try {
            const tx = await custodian.unlock(baseAccount, amountFoo, {from: baseAccount})
            truffleAssert.eventEmitted(tx, 'UnlockNative', (ev) => {
                return ev.to === baseAccount && ev.value.toString() === amountFoo
            })
        } catch (e) {
            assert.fail('it should not throw error unlocking native asset')
        }
    })

    it('should fail to unlock because insufficient balance', async () => {
        const custodian = await NativeAssetCustodian.new()
        const baseAccount = accounts[0]
        const amountFoo = '1000000000'
        try {
            const tx = await custodian.unlock(baseAccount, amountFoo, {from: baseAccount})
            truffleAssert.eventNotEmitted(tx, 'MintNative')
            assert.fail('it should throw error unlocking native asset')
        } catch (e) {
            assert.equal(e.reason, 'Native: unable to unlock the native asset, insufficient balance')
        }
    })
})