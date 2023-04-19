// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

// A subordinate token can be associated to any ERC721 token.
// However, it it is necessary that the subordinate token is visible on services
// like marketplaces, the dominant token must propagate any Transfer event to the subordinate

// ERC165 interface id is 0x48b041fd
interface IERC721DominantUpgradeable {
  // @dev It returns the address of subordinate tokens.
  // @param index The index of the subordinate token
  function subordinateByIndex(uint256 index) external view returns (address);

  function isSubordinate(address subordinate_) external view returns (bool);

  function countSubordinates() external view returns (uint);
}
