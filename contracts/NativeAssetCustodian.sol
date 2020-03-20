pragma solidity ^0.5.0;

/// @author Evrynet Team
/// @title The storage which holds a pre-minted native asset
contract NativeAssetCustodian {
    constructor() public payable {}

    event LockNative(address indexed owner, uint256 value);
    event UnlockNative(address indexed to, uint256 value);

    /// Lock the native asset to the contract
    function lock() external payable {
        emit LockNative(msg.sender, msg.value);
    }

    /// Unlock the native asset from the contract to the given address
    /// @param _value of native asset to be pay off
    function unlock(address payable _to, uint256 _value) external {
        require(
            address(this).balance >= _value,
            "Native: unable to unlock the native asset, insufficient balance"
        );
        _to.transfer(_value);
        emit UnlockNative(_to, _value);
    }
}
