// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./IERC721Subordinate.sol";
import "./ERC721Badge.sol";

/**
 * @dev Implementation of IERC721Subordinate interface.
 * Strictly based on OpenZeppelin's implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721]
 * in openzeppelin/contracts v4.8.0.
 */
contract ERC721Subordinate is IERC721Subordinate, ERC721Badge {
  using Address for address;
  using Strings for uint256;

  // dominant token contract
  IERC721 immutable private _dominant;

  mapping(uint256 => bool) private _initialTransfers;

  /**
   * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection
   * plus the contract of the dominant token.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    address dominant_
  ) ERC721Badge(name_, symbol_) {
    require(dominant_.isContract(), "ERC721Subordinate: not a contract");
    _dominant = IERC721(dominant_);
    require(_dominant.supportsInterface(type(IERC721).interfaceId), "ERC721Subordinate: dominant not IERC721");
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Badge) returns (bool) {
    return
      interfaceId == type(IERC721Subordinate).interfaceId ||
      interfaceId == type(IERC721).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721Subordinate}.
   */
  function dominantToken() public view override returns (address) {
    return address(_dominant);
  }

  /**
   * @dev See {IERC721-balanceOf}.
   */
  function balanceOf(address owner) public view virtual override returns (uint256) {
    return _dominant.balanceOf(owner);
  }

  /**
   * @dev See {IERC721-ownerOf}.
   */
  function ownerOf(uint256 tokenId) public view virtual override returns (address) {
    return _dominant.ownerOf(tokenId);
  }

  function emitTransfer(uint tokenId) external virtual override {
    require(!_initialTransfers[tokenId], "ERC721Subordinate: already generated");
    // if the token does not exist it will revert("ERC721: invalid token ID")
    address tokenOwner = IERC721(dominantToken()).ownerOf(tokenId);
    emit Transfer(address(0), tokenOwner, tokenId);
    _initialTransfers[tokenId] = true;
  }

}
