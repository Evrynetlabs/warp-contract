pragma solidity ^0.5.0;

import "../../contracts/StellarCreditCustodian.sol";
import "../../contracts/Metadata.sol";
import "../../contracts/lib/Convert.sol";
import "../utils/PayableThrowProxy.sol";
import "truffle/Assert.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";


contract TestUnlockStellarCredit {
    using Convert for address;

    EER2B credit;
    StellarCreditCustodian custodian;
    Metadata metadata;
    PayableThrowProxy user;
    uint256 creditIDFoo;

    function beforeAll() external {
        user = new PayableThrowProxy();
        credit = new EER2B();
        metadata = new Metadata("name", "issuer", 1);
        creditIDFoo = credit.create(address(metadata).toString(), false);

        custodian = new StellarCreditCustodian(address(credit), 1);
        custodian.add(creditIDFoo);
        credit.setMinter(creditIDFoo, address(custodian));
    }

    function testUnlockCredit() external {
        uint256 unlockingAmount = 1500;
        uint256 balanceBefore = credit.balanceOf(address(user), creditIDFoo);

        StellarCreditCustodian(address(user)).unlock(creditIDFoo, unlockingAmount);
        (bool success, ) = user.execute(address(custodian));

        Assert.isTrue(success, "should not throw error unlocking credit");

        uint256 balanceAfter = credit.balanceOf(address(user), creditIDFoo);
        Assert.equal(
            balanceAfter,
            balanceBefore + unlockingAmount,
            "user credit should increase per unlockingAmount"
        );
    }

    function testErrorUnlockNotSupportedCredit() external {
        uint256 unlockingAmount = 1500;
        uint256 creditIDBar = 1;

        StellarCreditCustodian(address(user)).unlock(creditIDBar, unlockingAmount);
        (bool success, ) = user.execute(address(custodian));

        Assert.isFalse(success, "should throw error unlocking not supported credit");
    }
}
