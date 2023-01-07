// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "./ERC721Subordinate.sol";

interface IERC721EnumerableExtended is IERC165, IERC721, IERC721Metadata, IERC721Enumerable {}

/**
 * @dev Implementation of IERC721Subordinate interface.
 * Strictly based on OpenZeppelin's implementation of enumerable https://eips.ethereum.org/EIPS/eip-721[ERC721]
 * in openzeppelin/contracts v4.8.0.
 */
contract ERC721SubordinateEnumerable is ERC721Subordinate, IERC721Enumerable {

  // address of the dominant token contract
  IERC721EnumerableExtended private _dominantEnumerable;

  /**
 * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection
 * plus the contract of the dominant token.
 */
  constructor(
    string memory name_,
    string memory symbol_,
    address dominant_
  ) ERC721Subordinate(name_, symbol_, dominant_) {
    _dominantEnumerable = IERC721EnumerableExtended(dominant_);
    require(_dominantEnumerable.supportsInterface(type(IERC721Enumerable).interfaceId), "ERC721Subordinate: dominant not IERC721Enumerable");
  }

  /**
 * @dev See {IERC165-supportsInterface}.
 */
  function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721Subordinate) returns (bool) {
    return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
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
}
