# Warp Protocol Contract
A set of contracts using in the Warp protocol to lock and unlock asset including
- Evrynet Original Credit
- Stellar Original Credit
- Evrynet native asset

### Usage
#### Warp agents
1. Deploy the custodian contracts while specifying a provider address of your choice
2. Add the asset to whitelist according to its type
    - Stellar Original Credit: asset that is created on Evrynet only for representing a credit on the Stellar
    - Evrynet Original Credit: other credits that is created in Evrynet
    - Evrynet native asset
3. Use the contract addresses to start a warp server *(see `github.com/Evrynetlabs/warp` for more details)*   

#### Warp users
1. Allow the custodian contracts to operate your Evrynet account by calling ```setApprovalForAll``` function of the credit contract *(see `github.com/Evrynetlabs/credit-contract` for more details)*

## Installing / Getting started
```console
$ npm install @evrynetlabs/warp-contract
```
## Developing
### Build With
- [Solidity](https://solidity.readthedocs.io/en/v0.5.0/index.html#)
- [Node js](https://nodejs.org/en/docs/)
### Prerequisites
- [Truffle](https://www.trufflesuite.com/docs/truffle/getting-started/installation)
- [NPM](https://www.npmjs.com/)
- [Yarn](https://yarnpkg.com/)
### Setting up Dev
```
$ npm install -g truffle 
$ npm install -g solc@0.5.0 
$ yarn install
```
### Building
```
$ yarn run build
```

## Versioning
We use a [SemVer](https://semver.org/) for versioning. Please see the [release](https://github.com/Evrynetlabs/credit-contract/releases).

## Test
```console
$ yarn run test
```

## Style guide
We use the following command to maintain the formatting and linting.
```
yarn run solhint
yarn run prettier:solidity
```

## Licensing
ERC20 Adapter is licensed under the [Open Software License ("OSL") v. 3.0](https://opensource.org/licenses/OSL-3.0), also included in our repository in the LICENSE file.