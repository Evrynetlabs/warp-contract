pragma solidity ^0.5.0;


library Convert {
    function toString(address _addr) public pure returns (string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(51);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function toAddress(string memory _str) public pure returns (address) {
        bytes memory tmp = bytes(_str);
        uint160 iaddr = 0;
        uint160 curr;
        uint160 next;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            curr = uint160(uint8(tmp[i]));
            next = uint160(uint8(tmp[i + 1]));
            if ((curr >= 97) && (curr <= 102)) {
                curr -= 87;
            } else if ((curr >= 65) && (curr <= 70)) {
                curr -= 55;
            } else if ((curr >= 48) && (curr <= 57)) {
                curr -= 48;
            }
            if ((next >= 97) && (next <= 102)) {
                next -= 87;
            } else if ((next >= 65) && (next <= 70)) {
                next -= 55;
            } else if ((next >= 48) && (next <= 57)) {
                next -= 48;
            }
            iaddr += (curr * 16 + next);
        }
        return address(iaddr);
    }
}
