pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/lib/Convert.sol";

contract TestConversion {
    using Convert for string;
    using Convert for address;

    string str = "0x0000000000000000000000000000000000000001";

    function testStringConvertToAddress() external {
        Assert.equal(address(1), str.toAddress(), "the result address should be equal to the expected address");
    }
    function testAddressConvertToString() external {
        address addr = str.toAddress();
        address fooAccount = address(1);
        Assert.equal(addr.toString(),fooAccount.toString(), "the result string should be equal to the expected string");
    }
}