// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

// A subordinate token can be associated to any ERC721 token.
// However, it it is necessary that the subordinate token is visible on services
// like marketplaces, the dominant token must propagate any Transfer event to the subordinate

// ERC165 interface id is 0x6ae735ff
interface IERC721DominantUpgradeable {
  // @dev It returns the address of subordinate tokens.
  // @param index The index of the subordinate token
  function subordinateTokens(uint256 index) external view returns (address);
}