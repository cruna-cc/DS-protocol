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

  error NotAnNFT();
  error TransferAlreadyEmitted();

  // dominant token contract
  IERC721 private immutable _dominant;

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
    _dominant = IERC721(dominant_);
    if (!_dominant.supportsInterface(type(IERC721).interfaceId)) revert NotAnNFT();
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

  function _allowTransfer(address) internal view virtual returns (bool) {
    // return _msgSender() == tokenOwner;
    return true;
  }

  function emitTransfer(uint256 tokenId) external virtual override {
    if (_initialTransfers[tokenId]) revert TransferAlreadyEmitted();
    // if the token does not exist it will revert("ERC721: invalid token ID")
    address tokenOwner = IERC721(dominantToken()).ownerOf(tokenId);
    _allowTransfer(tokenOwner);
    emit Transfer(address(0), tokenOwner, tokenId);
    _initialTransfers[tokenId] = true;
  }
}
