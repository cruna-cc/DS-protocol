// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./IERC721DefaultApprovable.sol";
import "./IERC721DefaultLockable.sol";

contract ERC721Badge is IERC721DefaultLockable, IERC721DefaultApprovable, ERC721 {
  constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    emit DefaultApprovable(false);
    emit DefaultLocked(true);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IERC721DefaultApprovable).interfaceId ||
      interfaceId == type(IERC721DefaultLockable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function approvable(uint256) external view returns (bool) {
    return false;
  }

  function locked(uint256) external view returns (bool) {
    return true;
  }

  function approve(address, uint256) public virtual override {
    revert("ERC721Badge: approvals not allowed");
  }

  function getApproved(uint256) public view virtual override returns (address) {
    return address(0);
  }

  function setApprovalForAll(address, bool) public virtual override {
    revert("ERC721Badge: approvals not allowed");
  }

  function isApprovedForAll(address, address) public view virtual override returns (bool) {
    return false;
  }

  function transferFrom(
    address,
    address,
    uint256
  ) public virtual override {
    revert("ERC721Badge: transfers not allowed");
  }

  function safeTransferFrom(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override {
    revert("ERC721Badge: transfers not allowed");
  }
}
