pragma solidity ^0.5.0;

import "../../contracts/StellarCreditCustodian.sol";
import "../../contracts/Metadata.sol";
import "../../contracts/lib/Convert.sol";
import "../utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";


contract TestMigrationVote {
    using Convert for address;

    EER2B credit;
    StellarCreditCustodian oldCustodian;
    StellarCreditCustodian newCustodian;
    Metadata metadata;
    uint256 creditIDFoo;

    function beforeEach() external {
        credit = new EER2B();
        metadata = new Metadata("name", "issuer", 1);
        creditIDFoo = credit.create(address(metadata).toString(), false);

        oldCustodian = new StellarCreditCustodian(address(credit), 2);
        newCustodian = new StellarCreditCustodian(address(credit), 2);
        oldCustodian.add(creditIDFoo);
        credit.setMinter(creditIDFoo, address(oldCustodian));
    }

    function testMigrationVote() external {
        ThrowProxy user = new ThrowProxy();
        StellarCreditCustodian(address(user)).migrationVote(address(newCustodian));
        (bool success, ) = user.execute(address(oldCustodian));
        Assert.isTrue(success, "should not throw error");
    }

    function testErrorDuplicatedVote() external {
        ThrowProxy user = new ThrowProxy();
        StellarCreditCustodian(address(user)).migrationVote(address(newCustodian));
        (bool success, ) = user.execute(address(oldCustodian));
        require(success, "should not throw error");

        (success, ) = user.execute(address(oldCustodian));
        require(!success, "should throw error duplicated proposal");
    }

    function testVoteReachThreshold() external {
        ThrowProxy user1 = new ThrowProxy();
        ThrowProxy user2 = new ThrowProxy();

        StellarCreditCustodian(address(user1)).migrationVote(address(newCustodian));
        (bool success, ) = user1.execute(address(oldCustodian));
        require(success, "should not throw error approving by user1");

        StellarCreditCustodian(address(user2)).migrationVote(address(newCustodian));
        (success, ) = user2.execute(address(oldCustodian));
        require(success, "should not throw error approving by user2");

        require(
            credit.minters(creditIDFoo) == address(newCustodian),
            "minter role should be migrated"
        );
    }
}
