const Credit = artifacts.require('@Evrynetlabs/credit-contract/contracts/EER2B.sol')
const StellarCreditCustodian = artifacts.require('StellarCreditCustodian')
const NativeAssetCustodian = artifacts.require('NativeAssetCustodian')
const EvrynetCreditCustodian = artifacts.require('EvrynetCreditCustodian')
const Metadata = artifacts.require('Metadata')
const Convert = artifacts.require('Convert')

module.exports = async function (deployer) {
    await deployer.link(Convert, StellarCreditCustodian)
    await deployer.link(Convert, EvrynetCreditCustodian)

    await deployer.deploy(Credit)
    await deployer.deploy(StellarCreditCustodian, Credit.address, 1)
    await deployer.deploy(NativeAssetCustodian, {
        value: '10000000000000000000'
    })
    await deployer.deploy(EvrynetCreditCustodian, Credit.address)

    await deployer.deploy(Metadata, "lumens", "issuer", 1)
}