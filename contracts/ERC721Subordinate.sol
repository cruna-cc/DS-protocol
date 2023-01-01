// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ERC721Subordinate is ERC721 {
  using Address for address;

  error NotAContract();
  error SubordinateTokensAreNotTransferable();

  ERC721 private _main;

  constructor(
    string memory name,
    string memory symbol,
    address main
  ) ERC721(name, symbol) {
    if (!main.isContract()) revert NotAContract();
    _main = ERC721(main);
  }

  function mainToken() public view returns (address) {
    return address(_main);
  }

  // core views

  function balanceOf(address owner) public view override(ERC721) returns (uint256) {
    return _main.balanceOf(owner);
  }

  function ownerOf(uint256 tokenId) public view override(ERC721) returns (address) {
    return _main.ownerOf(tokenId);
  }

  // no transfers 2

  function _beforeTokenTransfer(
    address,
    address,
    uint256,
    uint256
  ) internal override(ERC721) {
    revert SubordinateTokensAreNotTransferable();
  }

  // no approvals

  function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function approve(address, uint256) public override(ERC721) {
    revert SubordinateTokensAreNotTransferable();
  }

  function getApproved(uint256) public view override(ERC721) returns (address) {
    return address(0);
  }

  function setApprovalForAll(address, bool) public override(ERC721) {
    revert SubordinateTokensAreNotTransferable();
  }

  function isApprovedForAll(address, address) public view override(ERC721) returns (bool) {
    return false;
  }
}
