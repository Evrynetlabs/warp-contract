pragma solidity ^0.5.0;

import "./WhitelistAssets.sol";
import "@Evrynetlabs/credit-contract/contracts/IEER2TokenReceiver.sol";
import "./ICreditCustodian.sol";


contract EvrynetCreditCustodian is WhitelistAssets, IEER2TokenReceiver, ICreditCustodian {
    // onReceive function signatures
    bytes4 internal constant EER2_RECEIVED_VALUE = 0x09a23c29;
    bytes4 internal constant EER2_BATCH_RECEIVED_VALUE = 0xbaf5f228;

    constructor(address _credit) public WhitelistAssets(_credit) {}

    function unlock(uint256 _typeID, uint256 _value) external onlyWhitelistedAssets(_typeID) {
        credit.safeTransferFrom(address(this), msg.sender, _typeID, _value, bytes(""));
        emit Unlock(msg.sender, _typeID, _value);
    }

    function lock(uint256 _typeID, uint256 _value) external onlyWhitelistedAssets(_typeID) {
        credit.safeTransferFrom(msg.sender, address(this), _typeID, _value, bytes(""));
    }

    // EER2 implementation
    function onEER2Received(
        address _operator,
        address _from,
        uint256 _typeID,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4) {
        emit Lock(_operator, _from, _typeID, _value, _data);
        return EER2_RECEIVED_VALUE;
    }

    function onEER2BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _typeIDs,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4) {
        for (uint256 i = 0; i < _typeIDs.length; ++i) {
            uint256 typeID = _typeIDs[i];
            uint256 value = _values[i];
            emit Lock(_operator, _from, typeID, value, _data);
        }
        return EER2_BATCH_RECEIVED_VALUE;
    }
}
