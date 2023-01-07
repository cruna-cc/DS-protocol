// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./ERC721SubordinateUpgradeable.sol";

interface IERC721EnumerableExtended is IERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable, IERC721EnumerableUpgradeable {}

abstract contract ERC721EnumerableSubordinateUpgradeable is
Initializable, ERC721SubordinateUpgradeable, IERC721EnumerableUpgradeable {

  // address of the dominant token contract
  IERC721EnumerableExtended private _dominantEnumerable;

  // solhint-disable
  function __ERC721EnumerableSubordinate_init(
    string memory name_,
    string memory symbol_,
    address dominant_
  ) internal onlyInitializing {
    __ERC721Subordinate_init(name_, symbol_, dominant_);
    _dominantEnumerable = IERC721EnumerableExtended(dominant_);
    require(_dominantEnumerable.supportsInterface(type(IERC721EnumerableUpgradeable).interfaceId), "ERC721Subordinate: dominant not IERC721Enumerable");
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721SubordinateUpgradeable) returns (bool) {
    return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
   */
  function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
    return _dominantEnumerable.tokenOfOwnerByIndex(owner, index);
  }

  /**
   * @dev See {IERC721Enumerable-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _dominantEnumerable.totalSupply();
  }

  /**
   * @dev See {IERC721Enumerable-tokenByIndex}.
   */
  function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
    return _dominantEnumerable.tokenByIndex(index);
  }

  uint256[50] private __gap;
}
