// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

// A subordinate contract has no control on its own ownership.
// Whoever owns the main token owns the subordinate token.
// ERC165 interface id is 0x431694c0
interface IERC721Subordinate {
  // The function dominantToken() returns the address of the dominant token.
  function dominantToken() external view returns (address);

  // Most marketplaces do not see tokens that have not emitted an initial
  // transfer from address 0. This function allow to fix the issue, but
  // it is not mandatory — in same cases, the deployer may want the subordinate
  // being not visible on marketplaces.
  function emitTransfer(
    address from,
    address to,
    uint256 tokenId
  ) external;
}
