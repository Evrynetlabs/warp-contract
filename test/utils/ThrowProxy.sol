pragma solidity ^0.5.0;


contract ThrowProxy {
    bytes data;

    constructor() public {}

    //prime the data using the fallback function.
    function() external payable {
        data = msg.data;
    }

    function execute(address target) external returns (bool, bytes memory) {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            return target.call.value(address(this).balance)(data);
        }
        return target.call(data);
    }
}
