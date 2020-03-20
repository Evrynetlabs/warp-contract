pragma solidity ^0.5.0;


/**
  @title IMetadata
  @dev Interface of the Metadata standard for the Warp protocol

  Note: The ERC-165 identifier for this interface is 0x2ad5032c.
 */

interface IMetadata {
    /**
        @dev Returns the name of the credit
     */
    function name() external view returns (string memory);

    /**
        @dev Returns issuer of the credit
     */
    function issuer() external view returns (string memory);

    /**
        @dev Returns the number of decimals used to get its user representation.
        For example, if `decimals` equals `2`, a balance of `505` tokens should
        be displayed to a user as `5,05` (`505 / 10 ** 2`).
     
        Tokens usually opt for a value of 18, imitating the relationship between
        Ether and Wei. 
     */
    function decimals() external view returns (uint8);
}
