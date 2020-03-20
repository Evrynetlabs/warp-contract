pragma solidity ^0.5.0;

import "./IMetadata.sol";
import "@openzeppelin/contracts/introspection/IERC165.sol";


contract Metadata is IMetadata, IERC165 {
    string private _name;
    string private _issuer;
    uint8 private _decimals;

    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 private constant INTERFACE_SIGNATURE_METADATA = 0x2ad5032c;

    constructor(string memory name, string memory issuer, uint8 decimals) public {
        _name = name;
        _issuer = issuer;
        _decimals = decimals;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function issuer() external view returns (string memory) {
        return _issuer;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function supportsInterface(bytes4 _interfaceId) external view returns (bool) {
        if (
            _interfaceId == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceId == INTERFACE_SIGNATURE_METADATA
        ) {
            return true;
        }

        return false;
    }
}
