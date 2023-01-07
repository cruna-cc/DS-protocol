// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

interface IERC721SubordinateUpgradeable {
  // A subordinate contract has no control on its own ownership.
  // Whoever owns the main token owns the subordinate token.
  // The function dominantToken() returns the address of the main token.
  function dominantToken() external view returns (address);
}
