// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/IERC721Subordinate.sol";
import "./interfaces/IERC721Dominant.sol";

contract ERC721Dominant is IERC721Dominant, ERC721 {
  error NotOwnedByDominant(address subordinate, address dominant);
  error NotASubordinate(address subordinate);

  uint256 private _nextSubordinateId;
  mapping(uint256 => address) private _subordinates;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  function addSubordinate(address subordinate) public {
    if (ERC721(subordinate).supportsInterface(type(IERC721Subordinate).interfaceId) == false)
      revert NotASubordinate(subordinate);
    if (IERC721Subordinate(subordinate).dominantToken() != address(this)) revert NotOwnedByDominant(subordinate, address(this));
    _subordinates[_nextSubordinateId++] = subordinate;
  }

  function subordinateTokens(uint256 index) external view returns (address) {
    return _subordinates[index];
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
    return interfaceId == type(IERC721Dominant).interfaceId || super.supportsInterface(interfaceId);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721) {
    for (uint256 i = 0; i < _nextSubordinateId; i++) {
      address subordinate = _subordinates[i];
      if (subordinate != address(0)) {
        IERC721Subordinate(subordinate).emitTransfer(from, to, tokenId);
      }
    }
    super._afterTokenTransfer(from, to, tokenId, batchSize);
  }
}
