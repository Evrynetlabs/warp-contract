pragma solidity ^0.5.0;


interface ICreditCustodian {
    event Unlock(address indexed to, uint256 indexed typeID, uint256 value);
    event Lock(
        address indexed operator,
        address indexed from,
        uint256 indexed typeID,
        uint256 value,
        bytes data
    );

    function unlock(uint256 _typeID, uint256 _value) external;

    function lock(uint256 _typeID, uint256 _value) external;
}
