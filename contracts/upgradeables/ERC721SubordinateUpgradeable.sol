// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IERC721SubordinateUpgradeable.sol";
import "./ERC721BadgeUpgradeable.sol";

/**
 * @dev Implementation of IERC721Subordinate interface based on the
 * implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}. The reference implementation can be found in OpenZeppelin Contracts upgradeable v4.8.0.
 */
contract ERC721SubordinateUpgradeable is IERC721SubordinateUpgradeable, ERC721BadgeUpgradeable {
  using AddressUpgradeable for address;
  using StringsUpgradeable for uint256;

  error NotAnNFT();
  error TransferAlreadyEmitted();
  error OnlyDominant();

  // dominant token contract
  IERC721Upgradeable private _dominant;

  modifier onlyDominant() {
    if (msg.sender != address(_dominant)) revert OnlyDominant();
    _;
  }

  mapping(uint256 => bool) private _initialTransfers;

  // solhint-disable func-name-mixedcase
  function __ERC721Subordinate_init(
    string memory name_,
    string memory symbol_,
    address dominant_
  ) internal initializer {
    __ERC721Badge_init(name_, symbol_);
    _dominant = IERC721Upgradeable(dominant_);
    if (!_dominant.supportsInterface(type(IERC721Upgradeable).interfaceId)) revert NotAnNFT();
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721BadgeUpgradeable) returns (bool) {
    return
      interfaceId == type(IERC721SubordinateUpgradeable).interfaceId ||
      interfaceId == type(IERC721Upgradeable).interfaceId ||
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
    if (_initialTransfers[tokenId]) revert TransferAlreadyEmitted();
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

  uint256[50] private __gap;
}
