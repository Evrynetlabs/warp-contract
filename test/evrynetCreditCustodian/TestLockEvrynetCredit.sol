pragma solidity ^0.5.0;

import "../../contracts/EvrynetCreditCustodian.sol";
import "../../contracts/Metadata.sol";
import "../../contracts/lib/Convert.sol";
import "../utils/PayableThrowProxy.sol";
import "truffle/Assert.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";

contract TestLockEvrynetCredit {
    using Convert for address;

    EER2B credit;
    EvrynetCreditCustodian custodian;
    Metadata metadata;
    PayableThrowProxy user;
    uint256 creditIDFoo;

    uint256 initialAmount = 100;

    function beforeAll() external {
        credit = new EER2B();
        metadata = new Metadata("name", "issuer", 1);
        creditIDFoo = credit.create(address(metadata).toString(), false);

        user = new PayableThrowProxy();
        custodian = new EvrynetCreditCustodian(address(credit));
        custodian.add(creditIDFoo);

        address[] memory tos = new address[](1);
        uint256[] memory values = new uint256[](1);
        tos[0] = address(user);
        values[0] = initialAmount;
        credit.mintFungible(creditIDFoo, tos, values);

        EER2B(address(user)).setApprovalForAll(address(custodian), true);
        (bool success, ) = user.execute(address(credit));
        Assert.isTrue(success, "should give permission to evrynet credit custodian successfully");
    }

    function testLockCredit() external {
        uint256 lockingAmount = 10;
        uint256 userBalanceBefore = credit.balanceOf(address(user), creditIDFoo);
        uint256 custodianBalanceBefore = credit.balanceOf(address(custodian), creditIDFoo);

        EvrynetCreditCustodian(address(user)).lock(creditIDFoo, lockingAmount);
        (bool success, ) = user.execute(address(custodian));

        Assert.isTrue(success, "should not throw error locking credit");

        uint256 userBalanceAfter = credit.balanceOf(address(user), creditIDFoo);
        uint256 custodianBalanceAfter = credit.balanceOf(address(custodian), creditIDFoo);
        Assert.equal(
            userBalanceAfter,
            userBalanceBefore - lockingAmount,
            "user credit should decrease per lockingAmount"
        );
        Assert.equal(
            custodianBalanceAfter,
            custodianBalanceBefore + lockingAmount,
            "custodian credit should increase per lockingAmount"
        );
    }

    function testLockCreditWithProhibitedCredit() external {
        uint256 creditIDBar = 99;
        uint256 lockingAmount = 10;

        EvrynetCreditCustodian(address(user)).lock(creditIDBar, lockingAmount);
        (bool success, ) = user.execute(address(custodian));

        Assert.isFalse(success, "should throw error locking credit with prohibited credit");
    }

}
