pragma solidity ^0.5.0;

import "../../contracts/WhitelistAssets.sol";
import "../../contracts/Metadata.sol";
import "../../contracts/lib/Convert.sol";
import "./../utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "@evrynetlabs/credit-contract/contracts/EER2B.sol";


contract TestWhitelistAssetsRemoveAsset {
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

    function prepareForRemove(WhitelistAssets whitelistAssets) internal {
        WhitelistAssets(address(throwProxy)).add(creditIDFoo);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isTrue(success, "should not throw error adding creditIDFoo");
        Assert.equal(whitelistAssets.assets(creditIDFoo), true, "creditIDFoo should be registered");

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

    function testRemoveAssets() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));
        prepareForRemove(whitelistAssets);

        WhitelistAssets(address(throwProxy)).remove(creditIDFoo, creditIDBar);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isTrue(success, "should not throw error removing creditIDFoo");
        Assert.equal(
            whitelistAssets.assets(creditIDFoo),
            false,
            "creditIDFoo should not be registered"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDBar),
            0,
            "creditIDBar should be updated to point to root in linklist"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDFoo),
            0,
            "creditIDFoo should be updated to point to root in linklist"
        );

        WhitelistAssets(address(throwProxy)).remove(creditIDBar, 0);
        (success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isTrue(success, "should not throw error removing creditIDBar");
        Assert.equal(
            whitelistAssets.assets(creditIDBar),
            false,
            "creditIDBar should not be registered"
        );
        Assert.equal(
            whitelistAssets.linklist(0),
            0,
            "root should be updated to point to self in linklist"
        );
        Assert.equal(
            whitelistAssets.linklist(creditIDBar),
            0,
            "creditIDBar should be updated to point to root in linklist"
        );
    }

    function testErrorRemovingCreditIDZero() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));

        WhitelistAssets(address(throwProxy)).remove(0, 0);

        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isFalse(success, "should throw error removing credit ID zero");
    }

    function testErrorRemovingAssetWithIncorrectParameters() external {
        WhitelistAssets whitelistAssets = new WhitelistAssets(address(credit));
        prepareForRemove(whitelistAssets);

        WhitelistAssets(address(throwProxy)).remove(1000, 1000);
        (bool success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isFalse(success, "should throw error removing unregistered asset");

        WhitelistAssets(address(throwProxy)).remove(creditIDFoo, creditIDFoo);
        (success, ) = throwProxy.execute(address(whitelistAssets));
        Assert.isFalse(success, "should throw error removing creditIDFoo with incorrect prevID");
    }
}
