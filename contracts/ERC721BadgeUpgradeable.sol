// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./IERC721DefaultApprovable.sol";
import "./IERC721DefaultLockable.sol";

contract ERC721BadgeUpgradeable is IERC721DefaultLockable, IERC721DefaultApprovable, Initializable, ERC721Upgradeable, OwnableUpgradeable{

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function __ERC721Badge_init(string memory name_, string memory symbol_) internal initializer {
    __ERC721_init(name_, symbol_);
    __Ownable_init();
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
    revert("approvals not allowed");
  }

  function getApproved(uint256) public view virtual override returns (address) {
    return address(0);
  }

  function setApprovalForAll(address, bool) public virtual override {
    revert("approvals not allowed");
  }


  function isApprovedForAll(address, address) public view virtual override returns (bool) {
    return false;
  }

  function transferFrom(
    address,
    address,
    uint256
  ) public virtual override {
    revert("transfers not allowed");
  }

  function safeTransferFrom(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override {
    revert("transfers not allowed");
  }
}
