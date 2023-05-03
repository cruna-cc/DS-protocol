// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IERC721DominantUpgradeable.sol";
import "./interfaces/IERC721SubordinateUpgradeable.sol";

abstract contract ERC721DominantUpgradeable is
  IERC721DominantUpgradeable,
  Initializable,
  ERC721Upgradeable,
  ReentrancyGuardUpgradeable
{
  error NotOwnedByDominant(address subordinate, address dominant);
  error NotASubordinate(address subordinate);

  uint256 private _nextSubordinateId;
  mapping(uint256 => address) private _subordinates;

  // solhint-disable func-name-mixedcase
  function __ERC721Dominant_init(string memory name, string memory symbol) internal onlyInitializing {
    __ERC721_init(name, symbol);
    __ReentrancyGuard_init();
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable) returns (bool) {
    return interfaceId == type(IERC721DominantUpgradeable).interfaceId || super.supportsInterface(interfaceId);
  }

  function addSubordinate(address subordinate) public virtual {
    // this MUST be called by the owner of the dominant token
    // We do not use Ownable here to leave the implementor the option
    // to use AccessControl or other approaches. The following should
    // take care of it
    _canAddSubordinate();
    //
    if (ERC721Upgradeable(subordinate).supportsInterface(type(IERC721SubordinateUpgradeable).interfaceId) == false)
      revert NotASubordinate(subordinate);

    if (IERC721SubordinateUpgradeable(subordinate).dominantToken() != address(this))
      revert NotOwnedByDominant(subordinate, address(this));

    _subordinates[_nextSubordinateId++] = subordinate;
  }

  // _canAddSubordinate must be implemented by the contract that extends ERC721Dominant
  // Example:
  //   function _canAddSubordinate() internal override onlyOwner {}
  //
  function _canAddSubordinate() internal virtual;

  function subordinateByIndex(uint256 index) public view virtual returns (address) {
    return _subordinates[index];
  }

  function isSubordinate(address subordinate_) public view virtual override returns (bool) {
    for (uint256 i = 0; i < _nextSubordinateId; i++) {
      if (_subordinates[i] == subordinate_) {
        return true;
      }
    }
    return false;
  }

  function countSubordinates() public view virtual override returns (uint256) {
    return _nextSubordinateId;
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal virtual override(ERC721Upgradeable) nonReentrant {
    super._afterTokenTransfer(from, to, tokenId, batchSize);
    for (uint256 i = 0; i < _nextSubordinateId; i++) {
      address subordinate = _subordinates[i];
      if (subordinate != address(0)) {
        IERC721SubordinateUpgradeable(subordinate).emitTransfer(from, to, tokenId);
      }
    }
  }

  uint256[50] private __gap;
}
