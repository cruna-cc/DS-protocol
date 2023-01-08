// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

// ERC165 interface id is 0x60c8f291
interface IERC721Subordinate {

  // A subordinate contract has no control on its own ownership.
  // Whoever owns the main token owns the subordinate token.

  // The use cases where this is useful are many.
  // Some example:
  // - A token that represents a specific aspect of a dominant token.
  //      In Everdragons2, the dominant token is a dragon. The subordinate token is
  //      a PFP version of the dragon, that must follow the ownership of the dragon.
  // - A token that represent an asset of the dominant token.
  // - A token that adds missed features to the dominant token.

  // The function dominantToken() returns the address of the dominant token.
  function dominantToken() external view returns (address);

  // The dominant token has full control on the subordinate token.
  // All the functions of the subordinate token are delegated to the dominant token.

  // For example, the function ownerOf(uint256 tokenId) returns the owner of the main token.

  //    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
  //      return _dominant.ownerOf(tokenId);
  //    }

}
