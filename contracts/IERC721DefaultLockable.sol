// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

// erc165 interfaceId 0xb45a3c0e
interface IERC721DefaultLockable {
  // Must be emitted one time, when the contract is deployed,
  // defining the default status of any token that will be minted
  event DefaultLocked(bool locked);

  // Must be emitted any time the status changes
  event Locked(uint256 indexed tokenId, bool locked);

  // Returns the status of the token.
  // It should revert if the token does not exist.
  function locked(uint256 tokenId) external view returns (bool);
}
