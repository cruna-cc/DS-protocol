// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IERC721DominantUpgradeable.sol";
import "./interfaces/IERC721SubordinateUpgradeable.sol";

contract ERC721DominantUpgradeable is IERC721DominantUpgradeable, Initializable, ERC721Upgradeable {
  error NotOwnedByDominant(address subordinate, address dominant);
  error NotASubordinate(address subordinate);

  uint256 private _nextSubordinateId;
  mapping(uint256 => address) private _subordinates;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  // solhint-disable func-name-mixedcase
  function __ERC721Dominant_init(string memory name, string memory symbol) internal initializer {
    __ERC721_init(name, symbol);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable) returns (bool) {
    return interfaceId == type(IERC721DominantUpgradeable).interfaceId || super.supportsInterface(interfaceId);
  }

  function addSubordinate(address subordinate) public {
    if (ERC721Upgradeable(subordinate).supportsInterface(type(IERC721SubordinateUpgradeable).interfaceId) == false)
      revert NotASubordinate(subordinate);

    if (IERC721SubordinateUpgradeable(subordinate).dominantToken() != address(this))
      revert NotOwnedByDominant(subordinate, address(this));

    _subordinates[_nextSubordinateId++] = subordinate;
  }

  function subordinateTokens(uint256 index) external view returns (address) {
    return _subordinates[index];
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721Upgradeable) {
    for (uint256 i = 0; i < _nextSubordinateId; i++) {
      address subordinate = _subordinates[i];
      if (subordinate != address(0)) {
        IERC721SubordinateUpgradeable(subordinate).emitTransfer(from, to, tokenId);
      }
    }
    super._afterTokenTransfer(from, to, tokenId, batchSize);
  }

  uint256[50] private __gap;
}
