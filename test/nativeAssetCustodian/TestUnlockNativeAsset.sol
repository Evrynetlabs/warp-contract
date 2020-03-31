pragma solidity ^0.5.0;

import "../../contracts/NativeAssetCustodian.sol";
import "../utils/ThrowProxy.sol";
import "truffle/Assert.sol";


contract TestUnlockNativeAsset {
    uint256 public initialBalance = 100 wei;
    ThrowProxy user = new ThrowProxy();
    NativeAssetCustodian custodian;

    uint256 nativeContractInitialBalance = 10 wei;

    function testUnlockNative() external {
        uint256 unlockingAmount = 2 wei;
        uint256 userBalance = address(user).balance;

        custodian = (new NativeAssetCustodian).value(nativeContractInitialBalance)();
        Assert.equal(
            address(custodian).balance,
            nativeContractInitialBalance,
            "native custodian contract should have initial balance"
        );

        NativeAssetCustodian(address(user)).unlock(address(user), unlockingAmount);
        (bool success, ) = user.execute(address(custodian));
        Assert.isTrue(success, "should not throw error unlocking native asset");
        Assert.equal(
            address(user).balance,
            userBalance + unlockingAmount,
            "user's balance should increase by unlockingAmount"
        );
        Assert.equal(
            address(custodian).balance,
            nativeContractInitialBalance - unlockingAmount,
            "native custodian contract's balance decrease by unlockingAmount"
        );
    }

    function testErrorUnlockingWithContractNoBalance() external {
        custodian = new NativeAssetCustodian();
        uint256 unlockingAmount = 2 wei;

        NativeAssetCustodian(address(user)).unlock(address(user), unlockingAmount);
        (bool success, ) = user.execute(address(custodian));
        Assert.isFalse(success, "should throw error insufficient balance");
    }
}
