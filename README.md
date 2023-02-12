# ERC721Subordinate
A subordinate ERC721 contract is a type of non-fungible token (NFT) that follows the ownership of a dominant NFT, which can be an ERC721 contract that does not have any additional features.

## Why

In 2021, when we started Everdragons2, we had in mind of using the head of the dragons for a PFP token based on the Everdragons2 that you own. Here an example of a full dragon and just the head.

![Dragon](https://github.com/ndujaLabs/ERC721Subordinate/blob/main/assets/Soolhoth.png)

![DragonPFP](https://github.com/ndujaLabs/ERC721Subordinate/blob/main/assets/Soolhoth_PFP.png)

The question was, _Should we allow people to transfer the PFP separately from the primary NFT?_ It didn't make much sense. At the same time, how to avoid that?

ERC721Subordinate introduces a subordinate token that are owned by whoever owns the dominant token. In consequence of this, the subordinate token cannot be approved or transferred separately from the dominant token. It is transferred when the dominant token is transferred.

## The interface

``` solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

// ERC165 interface id is 0x60c8f291
interface IERC721Subordinate {

  // A subordinate contract has no control on its own ownership.
  // Whoever owns the main token owns the subordinate token.
  
  // The use cases where this is useful are many.
  // Some example:
  // - A token that represents a specific aspect of a dominant token.
  //      In Everdragons2, the dominant token is a dragon. The subordinate token is
  //      a PFP version of the dragon, that must follow the ownership of the dragon.
  // - A token that represent an asset of the dominant token.
  // - A token that adds missed features to the dominant token.

  // The function dominantToken() returns the address of the dominant token.
  function dominantToken() external view returns (address);

  // The dominant token has full control on the subordinate token.
  // All the functions of the subordinate token are delegated to the dominant token.

  // For example, the function ownerOf(uint256 tokenId) returns the owner of the main token.

  //    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
  //      return _dominant.ownerOf(tokenId);
  //    }

}
```

To avoid loops, it is paramount that the subordinate token sets the dominant token during the deployment and is not be able to change it.

## The implementation

Here is the implementation of the interface in this repository (at https://github.com/ndujaLabs/erc721subordinate/blob/main/contracts/ERC721Subordinate.sol).

``` solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Authors: Francesco Sullo <francesco@sullo.co>

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IERC721Subordinate.sol";

interface IERC721Extended is IERC165, IERC721, IERC721Metadata {}

/**
 * @dev Implementation of IERC721Subordinate interface.
 * Strictly based on OpenZeppelin's implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721]
 * in openzeppelin/contracts v4.8.0.
 */
contract ERC721Subordinate is IERC721Subordinate, ERC165, IERC721, IERC721Metadata {
  using Address for address;
  using Strings for uint256;

  // dominant token contract
  IERC721Extended immutable private _dominant;

  // Token name
  string private _name;

  // Token symbol
  string private _symbol;

  /**
   * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection
   * plus the contract of the dominant token.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    address dominant_
  ) {
    _name = name_;
    _symbol = symbol_;
    require(dominant_.isContract(), "ERC721Subordinate: not a contract");
    _dominant = IERC721Extended(dominant_);
    require(_dominant.supportsInterface(type(IERC721).interfaceId), "ERC721Subordinate: dominant not IERC721");
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
    return
      interfaceId == type(IERC721Subordinate).interfaceId ||
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
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
}
```

The repo includes subordinates of enumerable and the relative upgradeable versions. 

## How to use it

Install the dependencies
``` 
npm i @openzeppelin/contracts \
 @openzeppelin/contracts-upgradeable \
 @ndujalabs/erc721subordinate
```

A simple example:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@ndujalabs/erc721subordinate/contracts/ERC721Subordinate.sol";

contract MySubordinate is ERC721Subordinate {
  constructor(address myToken) ERC721Subordinate("MyToken", "MTK", myToken) {}
}
```

Another example, enumerable and upgradeable

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../ERC721EnumerableSubordinateUpgradeable.sol";

contract MySubordinateEnumerableUpgradeable is ERC721EnumerableSubordinateUpgradeable, UUPSUpgradeable {
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize(address myTokenEnumerableUpgradeable) public initializer {
    __ERC721EnumerableSubordinate_init("SuperToken", "SPT", myTokenEnumerableUpgradeable);
  }

  function _authorizeUpgrade(address newImplementation) internal virtual override {}

  function getInterfaceId() public pure returns (bytes4) {
    return type(IERC721SubordinateUpgradeable).interfaceId;
  }
}

```

## How it works

You initialize the subordinate token passing the address of the main token and the subordinate takes anything from that. Look at some example in mocks and the testing.

What makes the difference is the base token uri. Change that, and everything will work great.

## Similar proposal

There are similar proposal that moves in the same realm.

[EIP-6150: Hierarchical NFTs](https://github.com/ethereum/EIPs/blob/ad986045e87d1e659bf36541df6fc13315c59bd7/EIPS/eip-6150.md) (discussion at https://ethereum-magicians.org/t/eip-6150-hierarchical-nfts-an-extension-to-erc-721/12173) is a proposal for a new standard for non-fungible tokens (NFTs) on the Ethereum blockchain that would allow NFTs to have a hierarchical structure, similar to a filesystem. This would allow for the creation of complex structures, such as NFTs that contain other NFTs, or NFTs that represent collections of other NFTs. The proposal is currently in the discussion phase, and has not yet been implemented on the Ethereum network. ERC721Subordinate focuses instead on a simpler scenario, trying to solve a specific problem in the simplest possible way.

EIP-3652 (https://ethereum-magicians.org/t/eip-3652-hierarchical-nft/6963) is very similar to EIP-6150. Both requires all the node following the standard. ERC721Subordinate is very different because it allows to create subordinates of existing, immutable NFTs.

## Implementations

[Everdragons2PGP](https://github.com/ndujaLabs/everdragons2-core/blob/VP/contracts/Everdragons2PFP.sol)

Feel free to make a PR to add your contracts.

## History

**0.1.4**
- fix error in mock, not initializing UUPSUpgradeable

**0.1.3**
- remove unused dependencies (Context, ERC721Receiver)

**0.1.2**
- remove script for deployment, left from the template used to create the repo

**0.1.1**
- specify that _dominant is immutable, where possible

**0.1.0**
- code refactored to override the implementation of OpenZeppelin's ERC721 and ERC721Enumerable to remove all the warning due to unreachable code

**0.0.4**
- renamed init functions. Ex: `__ERC721SubordinateUpgradeable_init` >> `__ERC721Subordinate_init`

**0.0.3**
- make it work with Solidity 0.8.17, BREAKING previous support

**0.0.2**
- adding repo info to package.json

**0.0.1**
- first version

## Copyright

(c) 2022, Francesco Sullo <francesco@sullo.co>

## License

MIT
