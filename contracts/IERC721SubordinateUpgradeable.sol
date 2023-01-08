// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

// this interface is actually identical to IERC721Subordinate
// It is provided here as an upgradeable version following the
// way OpenZeppelin implements upgradeable contracts.

// ERC165 interface id is 0x60c8f291
interface IERC721SubordinateUpgradeable {
  // A subordinate contract has no control on its own ownership.
  // Whoever owns the main token owns the subordinate token.
  // The function dominantToken() returns the address of the dominant token.
  function dominantToken() external view returns (address);
}
