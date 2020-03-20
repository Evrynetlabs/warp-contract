## Warp Protocol Contract

### Big Picture
![Warp-Big-Picture](./images/warp-big-picture.png)

### Warp Contract
Warp Contract is a portal of the warp protocol on the EvryNet chain. It does only two things, lock and unlock a mirror credit (Stellar credit <==> EvryNet credit) which Only Drivers(Warp contract admin) can command. The warp does not support all kinds of asset but whitelist assets. It works together with the [WhitelistAssets](#whitelistassets-contract) contract. Once the lock/unlock function has been called, the warp contract will call the [Credit](#credit-contract) contract to do the ERC20 jobs plus mint and burn thing.

#### Contract Set Up
1. gives a whitelistAssets Contract in constructor

#### API

- [warp.lock](#warplock)
- [warp.unlock](#warpunlock)
- [warp.migrationPropose](#warpmigrationpropose)
- [warp.migrate](#warpmigrate)

##### warp.lock
  Burns amount of credit on the EvryNet chains

  Emit event Unlock(address indexed to, bytes32 indexed assetName, uint256 tokens);
##### parameters
  1. Uint256 - amount of token to be burn
##### returns
  Boolean - ok

##### warp.unlock
  Mints amount of credit on the EvryNet chains which mirror to the Stellar chains

  Emit event Lock(address indexed tokenOwner, bytes32 indexed assetName, uint256 tokens);
##### parameters
  1. Address - recipient's EvryNet address
  2. Bytes32 - asset name
  3. Uint256 - amount of asset to be minted
##### returns
  Boolean - ok

##### warp.migrationPropose
 Makes a Warp contract migretion proprosal

Only Admin Role can call this function

##### parameters
  1. Address - a new warp contract address
  2. Address - credit contract; the new warp contract will has an admin role on the credit contract and revoke the
  current warp contract from the credit contract.

##### returns
None

##### warp.migrate
 Adds a new Warp contract to all whitelist Credit contract and revokes itself from all Credit contracts 

Only Admin Role can call this function

Emit Migration Event

##### parameters
  1. Address - a new warp contract address
  2. Address - credit contract; the new warp contract will has an admin role on the credit contract and revoke the
  current warp contract from the credit contract.

##### returns
None

### WhitelistAssets Contract
WhitelistAssets contract is a contract that keeps a list of credit that [Warp](#warp-contract) contract can work with. Only accounts with Admin role can add or remove an asset to/from the whitelist.

#### Contract Set Up
1. call addAsset with credit address arg

#### API

- [whitelistAssets.addAsset](#whitelistAssetsaddAsset)
- [whitelistAssets.removeAsset](#whitelistAssetsremoveAsset)
- [whitelistAssets.creditAddr](#whitelistAssetscreditAddr)

##### whitelistAssets.addAsset
  Adds an asset to the whitelist

  Emit AddedAsset Event
##### parameters
  1. Bytes32 - Hex("Asset Name")
  2. Address - Credit contract address
##### returns
  Boolean - ok

##### whitelistAssets.removeAsset
  Removes an asset from the whitelist

  Emit RemovedAsset Event
##### parameters
  1. Bytes32 - Hex("Asset Name")
##### returns
  Boolean - ok

##### whitelistAssets.creditAddr
  Returns a credit address which identified by asset name
##### parameters
  1. Bytes32 - Hex("Asset Name")
##### returns
  Address - Credit contract address

### Credit Contract
Credit contract is a modified [ERC20](https://theethereum.wiki/w/index.php/ERC20_Token_Standard) contract which adds a mint and burn features to it. Only accounts with a Minter Role can mint a new credit.

#### Contract Set Up
1. give the following parameters:
    - name - unique name of the asset
    - symbol - asset aka
    - issuer - asset issuer's stellar address
    - decimals - asset decimals
2. assign the Warp contract to the minters group

#### API

- [credit.name](#creditname)
- [credit.symbol](#creditsymbol)
- [credit.decimals](#creditdecimals)
- [credit.issuer](#creditissuer)
- [credit.mint](#creditmint)
- [credit.burn](#creditburn)
- [credit.totalSupply](#credittotalSupply)
- [credit.balanceOf](#creditbalanceOf)
- [credit.transfer](#credittransfer)
- [credit.allowance](#creditallowance)
- [credit.approve](#creditapprove)
- [credit.transferFrom](#credittransferFrom)
- [credit.increaseAllowance](#creditincreaseAllowance)
- [credit.decreaseAllowance](#creditdecreaseAllowance)

##### credit.name
  Returns the credit name e.g, Bitcoin by Alice
##### parameters
  none
##### returns
  String - the credit name

##### credit.symbol
  Returns the credit symbol e.g., BTC
##### parameters
  none
##### returns
  String - the credit symbol

##### credit.decimals
  Returns the decimals precision of the credit
##### parameters
  none
##### returns
  Uint256 - the credit decimals

##### credit.issuer
  Return the credit issuer address (Stellar address)
##### parameters
  none
##### returns
  String - the credit issuer address

##### credit.mint
  Mints some amount of credit to a given address

Emits Transfer event
##### parameters
  1. Address - the receiving EvryNet address
  2. Uint256 - the amount of minting token
##### returns
  Boolean - minting status

##### credit.burn
  Burns some amount of the caller's credit

Emits Transfer event
##### parameters
  1. Address - Credit owner address
  2. Uint256 - the amount of tokens that will be burned
##### returns
  Boolean - burning status

##### credit.totalSupply
  Returns the amount of tokens in existence
##### parameters
  none
##### returns
  Uint256 - the total supply

##### credit.balanceOf
 Returns the amount of tokens owned by account
##### parameters
  1. Address - the address who owned the credit
##### returns
  Uint256 - the balance of the address

##### credit.transfer
  Moves amount from caller's account to recipient

Emits Transfer event
##### parameters
  1. Address - recipient
  2. Uint256 - amount
##### returns
  Boolean - transfer status

##### credit.allowance 
  Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom. This is zero by default.
  This value changes when approve or transferFrom are called.
##### parameters
  1. Address - owner
  2. Addess - spender
##### returns
  Boolean - ok

##### credit.approve
Sets amount as the allowance of spender over the caller's tokens.

Returns a boolean value indicating whether the operation succeeded.

> Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

Emits Approval event
##### parameters
  1. Address - spender
  2. Uint256 - amount
##### returns
  Boolean - approve status

##### credit.transferFrom
Moves amount tokens from sender to recipient using the allowance mechanism. amount is then deducted from the caller's allowance.

Returns a boolean value indicating whether the operation succeeded.

Emits Transfer event
##### parameters
  1. Address - sender
  2. Address - recipient
  3. Uint256 - amount
##### returns
  Boolean - transfer status

##### credit.increaseAllowance
Atomically increases the allowance granted to spender by the caller.

Emits an Approval event indicating the updated allowance.
##### parameters
  1. Address - spender
  2. Uint256 - added amount of credit

##### returns
  Boolean - ok

#### credit.decreaseAllowance
Atomically decrease the allowance granted to spender by the caller.

Emits an Approval event indicating the updated allowance.
##### parameters
  1. Address - spender
  2. Uint256 - added amount of credit

##### returns
  Boolean - ok

### Native Contract

#### API

[native.mint](#nativemint)
[native.burn](#nativeburn)
[native.totalBalance](#nativetotalbalance)

##### native.mint
 Mints some amount of EVRY coins to the destination account
 Only the account with Admin Role can call the function
 Emit MintNative Event
##### parameters
  1. Address - recipient account
  2. Uint256 - amount of coins to be minted
##### returns
None

##### native.burn
  Burns some amount of EVRY coins via payment to the contract operation
  Emit BurnNative Event
##### parameters
None
##### returns
None

##### native.totalBalance
  Returns a native account balance
##### parameters
None
##### returns
Uint256 - account balance

### TODO

- [X] Credit Contract
    - [X] Sol
    - [X] test
- [X] Native Contract
    - [X] Sol
    - [X] test
- [X] Warp Contract
    - [X] Sol
    - [X] test
    - [X] Credit contract integration
    - [ ] Native contract integration
    - [X] WhitelistAssets contract integration
- [X] Asset Whitelist Contract
    - [X] Sol
    - [X] test

### Credit

[Safe Sodility Libs](https://docs.openzeppelin.org/v2.3.0/get-started)

[Development Tool](https://www.trufflesuite.com/)
