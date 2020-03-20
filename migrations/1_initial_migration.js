const Migrations = artifacts.require('Migrations')
const TestMigrationVote = artifacts.require('TestMigrationVote')
const TestLockStellarCredit = artifacts.require('TestLockStellarCredit')
const TestUnlockStellarCredit = artifacts.require('TestUnlockStellarCredit')
const TestWhitelistAssetsAddAsset = artifacts.require('TestWhitelistAssetsAddAsset')
const TestWhitelistAssetsRemoveAsset = artifacts.require('TestWhitelistAssetsRemoveAsset')
const TestUnlockEvrynetCredit = artifacts.require("TestUnlockEvrynetCredit")
const TestLockEvrynetCredit = artifacts.require("TestLockEvrynetCredit")
const Convert = artifacts.require('Convert')

module.exports = function (deployer) {
  deployer.deploy(Migrations)

  deployer.deploy(Convert)
  deployer.link(Convert, [
    TestMigrationVote,
    TestUnlockStellarCredit,
    TestLockStellarCredit,
    TestWhitelistAssetsRemoveAsset,
    TestWhitelistAssetsAddAsset,
    TestUnlockEvrynetCredit,
    TestLockEvrynetCredit,
  ])
}
