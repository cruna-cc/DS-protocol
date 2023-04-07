// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IERC721Subordinate.sol";
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
  error OnlyDominant();

  // dominant token contract
  IERC721 private immutable _dominant;

  mapping(uint256 => bool) private _initialTransfers;

  modifier onlyDominant() {
    if (msg.sender != address(_dominant)) revert OnlyDominant();
    _;
  }

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
    // We do not check it is a dominant token to give the possibility to associate
    // subordinate tokens to any existing NFT. In this case, however, the token
    // should implement a function to emit Transfer events to be visible on offline
    // marketplaces (e.g. OpenSea) executed by an oracle when a dominant token is
    // transferred.
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

  function emitInitialTransfer(uint256 tokenId) external virtual {
    if (!_initialTransfers[tokenId]) revert TransferAlreadyEmitted();
    // if the token does not exist it will revert("ERC721: invalid token ID")
    address tokenOwner = _dominant.ownerOf(tokenId);
    _allowTransfer(tokenOwner);
    emit Transfer(address(0), tokenOwner, tokenId);
    _initialTransfers[tokenId] = true;
  }

  function emitTransfer(
    address from,
    address to,
    uint256 tokenId
  ) external virtual override onlyDominant {
    if (!_initialTransfers[tokenId]) {
      from = address(0);
      _initialTransfers[tokenId] = true;
    }
    emit Transfer(from, to, tokenId);
  }
}
