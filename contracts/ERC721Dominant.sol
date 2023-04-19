// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IERC721Subordinate.sol";
import "./interfaces/IERC721Dominant.sol";

contract ERC721Dominant is IERC721Dominant, ERC721, ReentrancyGuard {
  error NotOwnedByDominant(address subordinate, address dominant);
  error NotASubordinate(address subordinate);

  uint256 private _nextSubordinateId;
  mapping(uint256 => address) private _subordinates;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  function addSubordinate(address subordinate) public virtual {
    // this MUST be called by the owner of the dominant token
    // We do not use Ownable here to leave the implementor the option
    // to use AccessControl or other approaches
    // you can override it like, for example:
    //
    //    function addSubordinate(address subordinate) public onlyOwner {
    //      super.addSubordinate(subordinate);
    //    }
    //
    if (ERC721(subordinate).supportsInterface(type(IERC721Subordinate).interfaceId) == false)
      revert NotASubordinate(subordinate);
    if (IERC721Subordinate(subordinate).dominantToken() != address(this)) revert NotOwnedByDominant(subordinate, address(this));
    _subordinates[_nextSubordinateId++] = subordinate;
  }

  function subordinateByIndex(uint256 index) external virtual view returns (address) {
    return _subordinates[index];
  }

  function isSubordinate(address subordinate_) public virtual override view returns (bool) {
    for (uint i = 0; i < _nextSubordinateId; i++) {
      if (_subordinates[i] == subordinate_) {
        return true;
      }
    }
    return false;
  }

  function countSubordinates() external view override returns (uint) {
    return _nextSubordinateId;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
    return interfaceId == type(IERC721Dominant).interfaceId || super.supportsInterface(interfaceId);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal virtual override(ERC721) nonReentrant {
    super._afterTokenTransfer(from, to, tokenId, batchSize);
    // We perform this as last operation
    // Notice that there is no loop risk because a dominant will have in general
    // only 1 subordinate token. If it has more, it will be a very small number
    for (uint256 i = 0; i < _nextSubordinateId; i++) {
      address subordinate = _subordinates[i];
      if (subordinate != address(0)) {
        IERC721Subordinate(subordinate).emitTransfer(from, to, tokenId);
      }
    }
  }
}
