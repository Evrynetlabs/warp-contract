pragma solidity ^0.5.0;

import "../../contracts/StellarCreditCustodian.sol";
import "../../contracts/Metadata.sol";
import "../../contracts/lib/Convert.sol";
import "../utils/PayableThrowProxy.sol";
import "truffle/Assert.sol";
import "@evrynetlabs/credit-contract/contracts/EER2B.sol";


contract TestLockStellarCredit {
    using Convert for address;

    EER2B credit;
    StellarCreditCustodian custodian;
    Metadata metadata;
    PayableThrowProxy user;
    uint256 creditIDFoo;

    function beforeAll() external {
        credit = new EER2B();
        metadata = new Metadata("name", "issuer", 1);
        creditIDFoo = credit.create(address(metadata).toString(), false);

        user = new PayableThrowProxy();

        custodian = new StellarCreditCustodian(address(credit), 1);
        custodian.add(creditIDFoo);
        credit.setMinter(creditIDFoo, address(custodian));

        StellarCreditCustodian(address(user)).unlock(creditIDFoo, 10000);
        (bool success, ) = user.execute(address(custodian));
        Assert.isTrue(success, "should unlock credit successfully");

        EER2B(address(user)).setApprovalForAll(address(custodian), true);
        (success, ) = user.execute(address(credit));
        Assert.isTrue(success, "should give permission to custodian successfully");
    }

    function testLockCredit() external {
        uint256 lockingAmount = 1500;
        uint256 balanceBefore = credit.balanceOf(address(user), creditIDFoo);

        StellarCreditCustodian(address(user)).lock(creditIDFoo, lockingAmount);
        (bool success, ) = user.execute(address(custodian));

        Assert.isTrue(success, "should not throw error locking user credit");

        uint256 balanceAfter = credit.balanceOf(address(user), creditIDFoo);
        Assert.equal(
            balanceAfter,
            balanceBefore - lockingAmount,
            "user credit should decrease per lockingAmount"
        );
    }

    function testErrorLockNotSupportedCredit() external {
        uint256 lockingAmount = 1500;
        uint256 creditIDBar = 1;

        StellarCreditCustodian(address(user)).lock(creditIDBar, lockingAmount);
        (bool success, ) = user.execute(address(custodian));

        Assert.isFalse(success, "should throw error locking not supported credit");
    }
}
