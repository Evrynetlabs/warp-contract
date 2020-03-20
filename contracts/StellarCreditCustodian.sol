pragma solidity ^0.5.0;

import "./WhitelistAssets.sol";
import "./ICreditCustodian.sol";

contract StellarCreditCustodian is WhitelistAssets, ICreditCustodian {
    struct MigrateProposal {
        // mapping of signer to sign state
        mapping(address => bool) signature;
        // accumulated signature counter on the proposal
        uint16 count;
    }
    uint16 private threshold;
    // mapping of a new contract to a mapping of credit contract to the migration proposal
    mapping(address => MigrateProposal) private proposals;

    constructor(address _credit, uint16 _threshold)
        public
        WhitelistAssets(_credit)
    {
        threshold = _threshold;
    }

    event Migrate(address indexed to);

    /// @notice makes a migration vote to migrate credit contract binding to a new contract
    /// also triggers the migration process when the migration vote threshold has reached
    /// @param _to the new contract to replace this contract
    function migrationVote(address _to) external {
        MigrateProposal storage proposal = proposals[_to];
        require(
            proposal.signature[msg.sender] != true,
            "Migration: Sender has already made a proposal"
        );
        proposal.signature[msg.sender] = true;
        proposal.count = proposal.count + 1;
        if (proposal.count >= threshold) {
            WhitelistAssets whitelist = WhitelistAssets(_to);
            for (
                uint256 creditID = linklist[0];
                creditID != 0;
                creditID = linklist[creditID]
            ) {
                credit.setMinter(creditID, _to);
                whitelist.add(creditID);
            }
            emit Migrate(_to);
        }
    }

    /// @notice Lock user token the same amount of token will be unlocked on the stellar
    /// @param _typeID the ID of credit to be locked
    /// @param _value amount of tokens to be locked
    function lock(uint256 _typeID, uint256 _value)
        external
        onlyWhitelistedAssets(_typeID)
    {
        credit.burnFungible(_typeID, msg.sender, _value);
        emit Lock(address(this), msg.sender, _typeID, _value, bytes(""));
    }

    /// @notice Transfers some valid token to the destination address. The same amount of token on the stellar
    /// will be locked in the stellar lock up account.
    /// @param _typeID the ID of credit to be transferred
    /// @param _value amount of tokens to be transferred
    function unlock(uint256 _typeID, uint256 _value)
        external
        onlyWhitelistedAssets(_typeID)
    {
        address[] memory tos = new address[](1);
        uint256[] memory values = new uint256[](1);
        tos[0] = msg.sender;
        values[0] = _value;

        credit.mintFungible(_typeID, tos, values);
        emit Unlock(msg.sender, _typeID, _value);
    }
}
