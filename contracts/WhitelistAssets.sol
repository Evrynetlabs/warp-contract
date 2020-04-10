pragma solidity ^0.5.0;

import "./Metadata.sol";
import "./lib/Convert.sol";
import "@evrynetlabs/credit-contract/contracts/EER2B.sol";
import "@openzeppelin/contracts/introspection/IERC165.sol";


/// WhitelistAssets keeps a whitelist assets record which warp allows to move cross chain
contract WhitelistAssets {
    using Convert for string;

    mapping(uint256 => bool) public assets;
    mapping(uint256 => uint256) public linklist;

    EER2B internal credit;

    bytes4 private constant INTERFACE_SIGNATURE_METADATA = 0x2ad5032c;

    constructor(address _credit) public {
        credit = EER2B(_credit);
    }

    modifier onlyWhitelistedAssets(uint256 _typeID) {
        require(assets[_typeID], "WhitelistAssets: the credit is prohibited");
        _;
    }

    /// @dev AddedAsset MUST emit when credit ID is added to the whitelist
    /// @param typeID the ID of the added credit
    event AddedAsset(uint256 indexed typeID);

    /// Add a new asset the whitelist asset database
    /// @param _typeID the ID of credit being added
    function add(uint256 _typeID) external {
        require(
            assets[_typeID] == false,
            "WhitelistAssets: cannot add the asset that has already been in the whitelist"
        );
        require(_typeID != 0, "WhitelistAssets: the credit id cannot be zero");
        require(
            IERC165(credit.metalinks(_typeID).toAddress()).supportsInterface(
                INTERFACE_SIGNATURE_METADATA
            ),
            "WhitelistAssets: the metadata contract is not supported interface"
        );
        assets[_typeID] = true;
        linklist[_typeID] = linklist[0];
        linklist[0] = _typeID;
        emit AddedAsset(_typeID);
    }

    /// @dev RemovedAsset MUST emit when credit ID is removed to the whitelist
    /// @param typeID the ID of the removed credit
    event RemovedAsset(uint256 indexed typeID);

    /// remove an asset from the whitelist asset database
    /// @param _typeID the ID of credit being removed
    /// @param _prevTypeID the prior credit ID in the linklist
    function remove(uint256 _typeID, uint256 _prevTypeID) external {
        require(_typeID != 0, "WhitelistAssets: the credit id cannot be zero");
        require(linklist[_prevTypeID] == _typeID, "WhitelistAssets: invalid remove argument");
        assets[_typeID] = false;
        linklist[_prevTypeID] = linklist[_typeID];
        linklist[_typeID] = 0;
        emit RemovedAsset(_typeID);
    }
}
