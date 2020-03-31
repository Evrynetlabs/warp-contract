## Warp Protocol Contract

A set of contracts using in the Warp protocol to lock and unlock asset including
- Evrynet Original Credit
- Stellar Original Credit
- Evrynet native asset

## Overview

### Installation
```
$ npm install git+ssh://git@github.com:/Evrynetlabs/warp-contract
```

#### Usage
##### Warp agents
1. Deploy the custodian contracts while specifying a provider address of your choice
2. Add the asset to whitelist according to its type
    - Stellar Original Credit: asset that is created on Evrynet only for representing a credit on the Stellar
    - Evrynet Original Credit: other credits that is created in Evrynet
    - Evrynet native asset
3. Use the contract addresses to start a warp server *(see `github.com/Evrynetlabs/warp` for more details)*   

##### Warp users
1. Allow the custodian contracts to operate your Evrynet account by calling ```setApprovalForAll``` function of the credit contract *(see `github.com/Evrynetlabs/credit-contract` for more details)*