pragma solidity ^0.5.0;

import "../utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "@evrynetlabs/credit-contract/contracts/EER2B.sol";
import "../../contracts/EvrynetCreditCustodian.sol";


contract TestEER2Received {
    bytes4 internal constant EER2_RECEIVED_VALUE = 0x09a23c29;
    bytes4 internal constant EER2_BATCH_RECEIVED_VALUE = 0xbaf5f228;

    ThrowProxy user = new ThrowProxy();
    EER2B credit;
    EvrynetCreditCustodian custodian;

    function beforeAll() external {
        credit = new EER2B();
        custodian = new EvrynetCreditCustodian(address(credit));
    }

    function testOnEER2Received() external {
        address addressFoo = address(1);
        uint256 amountFoo = 1000;
        bytes memory dataFoo = bytes("foo");
        uint256 creditIDFoo = 1;

        bytes4 value = custodian.onEER2Received(
            addressFoo,
            addressFoo,
            creditIDFoo,
            amountFoo,
            dataFoo
        );
        Assert.equal(EER2_RECEIVED_VALUE, value, "should value equal to EER2_RECEIVED_VALUE");
    }

    function testOnEER2BatchReceived() external {
        address addressFoo = address(1);
        uint256 amountFoo = 1000;
        bytes memory dataFoo = bytes("foo");
        uint256 creditIDFoo = 1;
        uint256[] memory ids = new uint256[](2);
        uint256[] memory values = new uint256[](2);
        ids[0] = creditIDFoo;
        ids[1] = creditIDFoo;
        values[0] = amountFoo;
        values[1] = amountFoo;

        bytes4 value = custodian.onEER2BatchReceived(addressFoo, addressFoo, ids, values, dataFoo);
        Assert.equal(
            EER2_BATCH_RECEIVED_VALUE,
            value,
            "should value equal to EER2_BATCH_RECEIVED_VALUE"
        );
    }
}
