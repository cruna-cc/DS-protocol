// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./IERC721SubordinateUpgradeable.sol";

interface IERC721Extended is IERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {}

/**
 * @dev Implementation of IERC721Subordinate interface based on the
 * implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}. The reference implementation can be found in OpenZeppelin Contracts upgradeable v4.8.0.
 */
contract ERC721SubordinateUpgradeable is
IERC721SubordinateUpgradeable,
Initializable,
ERC165Upgradeable,
IERC721Upgradeable,
IERC721MetadataUpgradeable
{
  using AddressUpgradeable for address;
  using StringsUpgradeable for uint256;

  // dominant token contract
  IERC721Extended private _dominant;

  // Token name
  string private _name;

  // Token symbol
  string private _symbol;


  /**
   * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
   */
  // solhint-disable
  function __ERC721Subordinate_init(string memory name_, string memory symbol_, address dominant_) internal initializer {
    __ERC165_init_unchained();
    _name = name_;
    _symbol = symbol_;
    require(dominant_.isContract(), "ERC721Subordinate: not a contract");
    _dominant = IERC721Extended(dominant_);
    require(_dominant.supportsInterface(type(IERC721Upgradeable).interfaceId), "ERC721Subordinate: dominant not IERC721");
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
  public
  view
  virtual
  override(ERC165Upgradeable, IERC165Upgradeable)
  returns (bool)
  {
    return
    interfaceId == type(IERC721SubordinateUpgradeable).interfaceId ||
    interfaceId == type(IERC721Upgradeable).interfaceId ||
    interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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

  /**
   * @dev See {IERC721Metadata-name}.
   */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {IERC721Metadata-symbol}.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    try _dominant.tokenURI(tokenId) returns (string memory) {
    } catch (
      bytes memory /*lowLevelData*/
    ) {
      revert("ERC721Metadata: URI query for nonexistent token");
    }
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
  }

  /**
   * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
   * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
   * by default, can be overridden in child contracts.
   */
  function _baseURI() internal view virtual returns (string memory) {
    return "";
  }

  /**
   * @dev See {IERC721-approve}.
   */
  function approve(address, uint256) public virtual override {
    revert("ERC721Subordinate: approvals not allowed");
  }

  /**
   * @dev See {IERC721-getApproved}.
   */
  function getApproved(uint256) public view virtual override returns (address) {
    return address(0);
  }

  /**
   * @dev See {IERC721-setApprovalForAll}.
   */
  function setApprovalForAll(address, bool) public virtual override {
    revert("ERC721Subordinate: approvals not allowed");
  }

  /**
   * @dev See {IERC721-isApprovedForAll}.
   */
  function isApprovedForAll(address, address) public view virtual override returns (bool) {
    return false;
  }

  /**
   * @dev See {IERC721-transferFrom}.
   */
  function transferFrom(
    address,
    address,
    uint256
  ) public virtual override {
    revert("ERC721Subordinate: transfers not allowed");
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(
    address,
    address,
    uint256
  ) public virtual override {
    revert("ERC721Subordinate: transfers not allowed");
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override {
    revert("ERC721Subordinate: transfers not allowed");
  }

  uint256[50] private __gap;
}
