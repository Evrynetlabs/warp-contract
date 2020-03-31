pragma solidity ^0.5.0;

import "../../contracts/WhitelistAssets.sol";
import "../../contracts/Metadata.sol";
import "../../contracts/lib/Convert.sol";
import "./../utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";


contract TestWhitelistAssetsAddAsset {
    using Convert for address;

    EER2B credit;
    Metadata metadata;
    uint256 creditIDFoo;
    uint256 creditIDBar;

    ThrowProxy throwProxy = new ThrowProxy();

    function beforeAll() external {
        credit = new EER2B();
        metadata = new Metadata("name", "issuer", 1);
        creditIDFoo = credit.create(address(metadata).toString(), false);
        creditIDBar = credit.create(address(metadata).toString(), false);
    }

    function testInitWhitelistAssetContract() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));
        Assert.equal(whitelistAssets.linklist(0), 0, "new linklist should be empty");
    }

    function testAddAssets() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));

        Assert.equal(
            whitelistAssets.assets(creditIDFoo),
            false,
            "creditIDFoo should not be registered"
        );
        Assert.equal(
            whitelistAssets.assets(creditIDBar),
            false,
            "creditIDBar should not be registered"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDFoo),
            0,
            "creditIDFoo should point to the root address in linklist"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDBar),
            0,
            "creditIDBar should point to the root address in linklist"
        );

        WhitelistAssets(address(throwProxy)).add(creditIDFoo);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isTrue(success, "should not throw error adding creditIDFoo");
        Assert.equal(whitelistAssets.assets(creditIDFoo), true, "creditIDFoo should be registered");
        Assert.equal(
            whitelistAssets.linklist(0),
            creditIDFoo,
            "root should point to creditIDFoo in linklist"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDFoo),
            0,
            "creditIDFoo should point to the root in linklist"
        );

        WhitelistAssets(address(throwProxy)).add(creditIDBar);
        (success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isTrue(success, "should not throw error adding creditIDBar");
        Assert.equal(whitelistAssets.assets(creditIDBar), true, "creditIDBar should be registered");
        Assert.equal(
            whitelistAssets.linklist(0),
            creditIDBar,
            "root should point to creditIDBar in linklist"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDBar),
            creditIDFoo,
            "creditIDBar should point to creditIDFoo in linklist"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDFoo),
            0,
            "creditIDFoo should point to root in linklist"
        );
    }

    function testErrorAddingAssetIDZero() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));

        Assert.equal(whitelistAssets.assets(0), false, "credit ID zero should not be registered");
        WhitelistAssets(address(throwProxy)).add(0);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isFalse(success, "it should throw error due to adding credit ID zero");
    }

    function testErrorAddingDuplicateCreditID() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));

        Assert.equal(
            whitelistAssets.assets(creditIDFoo),
            false,
            "creditIDFoo should not be registered"
        );
        WhitelistAssets(address(throwProxy)).add(creditIDFoo);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isTrue(success, "it should not throw error adding creditIDFoo for the first time");
        Assert.equal(whitelistAssets.assets(creditIDFoo), true, "creditIDFoo should be registered");

        WhitelistAssets(address(throwProxy)).add(creditIDFoo);
        (success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isFalse(
            success,
            "it should throw error due to adding creditIDFoo for the second time"
        );
    }

    function testErrorAddingCreditIDWithNoMetaDataSupport() external {
        uint256 badID = credit.create("not supported metalink", false);
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));

        Assert.equal(whitelistAssets.assets(badID), false, "badID should not be registered");
        WhitelistAssets(address(throwProxy)).add(badID);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isFalse(
            success,
            "it should throw error due to adding metadata contract is not supported interface"
        );
    }
}
