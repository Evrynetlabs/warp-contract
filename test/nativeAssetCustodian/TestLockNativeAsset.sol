pragma solidity ^0.5.0;

import "../../contracts/NativeAssetCustodian.sol";
import "../utils/ThrowProxy.sol";
import "truffle/Assert.sol";


contract TestLockNativeAsset {
    uint256 public initialBalance = 100 wei;
    NativeAssetCustodian custodian = new NativeAssetCustodian();
    ThrowProxy user = new ThrowProxy();

    function testLock() external {
        uint256 lockingAmount = 2 wei;
        uint256 custodianBalance = address(custodian).balance;

        NativeAssetCustodian(address(user)).lock.value(lockingAmount)();
        (bool success, ) = user.execute(address(custodian));
        Assert.isTrue(success, "should not throw error");
        Assert.equal(
            address(custodian).balance,
            custodianBalance + lockingAmount,
            "native contract's balance should increase by locking amount"
        );
    }
}
