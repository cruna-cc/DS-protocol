# ERC721Subordinate
A subordinate ERC721 contract is a type of non-fungible token (NFT) that follows the ownership of a dominant NFT, which can be an ERC721 contract that does not have any additional features.

## BE CAREFUL — This is a work in progress and changes are likely to happen. Use at your own risk. Wait for version 1.0.0 before using in production.


## Why

In 2021, when we started Everdragons2, we had in mind of using the head of the dragons for a PFP token based on the Everdragons2 that you own. Here an example of a full dragon and just the head.

![Dragon](https://github.com/ndujaLabs/ERC721Subordinate/blob/main/assets/Soolhoth.png)

![DragonPFP](https://github.com/ndujaLabs/ERC721Subordinate/blob/main/assets/Soolhoth_PFP.png)

The question was, _Should we allow people to transfer the PFP separately from the primary NFT?_ It didn't make much sense. At the same time, how to avoid that?

ERC721Subordinate introduces a subordinate token that are owned by whoever owns the dominant token. In consequence of this, the subordinate token cannot be approved or transferred separately from the dominant token. It is transferred when the dominant token is transferred.

## The interface

``` solidity
// A subordinate contract has no control on its own ownership.
// Whoever owns the main token owns the subordinate token.
// ERC165 interface id is 0x431694c0
interface IERC721Subordinate {
  // The function dominantToken() returns the address of the dominant token.
  function dominantToken() external view returns (address);

  // Most marketplaces do not see tokens that have not emitted an initial
  // transfer from address 0. This function allow to fix the issue, but
  // it is not mandatory — in same cases, the deployer may want the subordinate
  // being not visible on marketplaces.
  function emitTransfer(
    address from,
    address to,
    uint256 tokenId
  ) external;
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

```

The repo includes also an upgradeable version. 

## The foundation blocks

### IERC721DefaultApprovable

```solidity
// SPDX-License-Identifier: GPL3
pragma solidity ^0.8.17;

// Author: Francesco Sullo <francesco@sullo.co>

// erc165 interfaceId 0xbfdf8f79
interface IERC721DefaultApprovable {
  // Must be emitted when the contract is deployed.
  event DefaultApprovable(bool approvable);

  // Must be emitted any time the status changes.
  event Approvable(uint256 indexed tokenId, bool approvable);

  // Returns true if the token is approvable.
  // It should revert if the token does not exist.
  function approvable(uint256 tokenId) external view returns (bool);

  // A contract implementing this interface should not allow
  // the approval for all. So, any actor validating this interface
  // should assume that the tokens are not approvable for all.

  // An extension of this interface may include info about the
  // approval for all, but it should be considered as a separate
  // feature, not as a replacement of this interface.
}
```

### IERC721DefaultLockable

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

// erc165 interfaceId 0xb45a3c0e
interface IERC721DefaultLockable {
  // Must be emitted one time, when the contract is deployed,
  // defining the default status of any token that will be minted
  event DefaultLocked(bool locked);

  // Must be emitted any time the status changes
  event Locked(uint256 indexed tokenId, bool locked);

  // Returns the status of the token.
  // It should revert if the token does not exist.
  function locked(uint256 tokenId) external view returns (bool);
}
```

### ERC721Badge

It implements the IERC721DefaultApprovable and the IERC721DefaultLockable interfaces.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./IERC721DefaultApprovable.sol";
import "./IERC721DefaultLockable.sol";

contract ERC721Badge is IERC721DefaultLockable, IERC721DefaultApprovable, ERC721{
  constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    emit DefaultApprovable(false);
    emit DefaultLocked(true);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
    interfaceId == type(IERC721DefaultApprovable).interfaceId ||
    interfaceId == type(IERC721DefaultLockable).interfaceId ||
    super.supportsInterface(interfaceId);
  }

  function approvable(uint256) external view returns (bool) {
    return false;
  }

  function locked(uint256) external view returns (bool) {
    return true;
  }

  function approve(address, uint256) public virtual override {
    revert("approvals not allowed");
  }

  function getApproved(uint256) public view virtual override returns (address) {
    return address(0);
  }

  function setApprovalForAll(address, bool) public virtual override {
    revert("approvals not allowed");
  }


  function isApprovedForAll(address, address) public view virtual override returns (bool) {
    return false;
  }

  function transferFrom(
    address,
    address,
    uint256
  ) public virtual override {
    revert("transfers not allowed");
  }

  function safeTransferFrom(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override {
    revert("transfers not allowed");
  }
}
```

## How to use it

Install the dependencies like
``` 
npm i @openzeppelin/contracts \
 @openzeppelin/contracts-upgradeable \
 @ndujalabs/erc721subordinate
```

## How it works

You initialize the subordinate token passing the address of the main token and the subordinate takes anything from that. Look at some example in mocks and the testing.

What makes the difference is the base token uri. Change that, and everything will work great.

A simple example:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@ndujalabs/erc721subordinate/contracts/ERC721Subordinate.sol";

contract MySubordinate is ERC721Subordinate {
  constructor(address myToken) ERC721Subordinate("MyToken", "MTK", myToken) {}
}
```

Another example, upgradeable

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../ERC721SubordinateUpgradeable.sol";

contract MySubordinateUpgradeable is ERC721SubordinateUpgradeable, UUPSUpgradeable {
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
Notice that there is no reason to make the subordinate enumerable because we can query the dominant token to get all the ID owned by someone and apply that to the subordinate.

## Similar proposal

There are similar proposal that moves in the same realm.

[EIP-6150: Hierarchical NFTs](https://github.com/ethereum/EIPs/blob/ad986045e87d1e659bf36541df6fc13315c59bd7/EIPS/eip-6150.md) (discussion at https://ethereum-magicians.org/t/eip-6150-hierarchical-nfts-an-extension-to-erc-721/12173) is a proposal for a new standard for non-fungible tokens (NFTs) on the Ethereum blockchain that would allow NFTs to have a hierarchical structure, similar to a filesystem. This would allow for the creation of complex structures, such as NFTs that contain other NFTs, or NFTs that represent collections of other NFTs. The proposal is currently in the discussion phase, and has not yet been implemented on the Ethereum network. ERC721Subordinate focuses instead on a simpler scenario, trying to solve a specific problem in the simplest possible way.

EIP-3652 (https://ethereum-magicians.org/t/eip-3652-hierarchical-nft/6963) is very similar to EIP-6150. Both requires all the node following the standard. ERC721Subordinate is very different because it allows to create subordinates of existing, immutable NFTs, if it is not necessary to show the subordinate on marketplaces.

## Implementations

[Everdragons2PFP](https://github.com/ndujaLabs/everdragons2-core/blob/VP/contracts/Everdragons2PFP.sol)

[Cruna Protocol](https://github.com/cruna_cc/cruna-protocol)

Feel free to make a PR to add your contracts.

## History

**0.6.2**
- fixing more missing virtual statement in dominant tokens

**0.6.1**
- fixing missing virtual statement in dominant tokens

**0.6.0**
- (breaking change) add explicit reference to subordinate in dominant, so that the dominant can propagate the emission of Transfer events to the subordinate. It is necessary to emit Transfer events in the subordinate, because offline services, like marketplaces, index Transfer events in order to list the tokens. However, it is not mandatory and a project can decide to keep its subordinates not visible in the marketplaces.

**0.5.2**
- using revert error() instead of require(false, "message")

**0.5.1**
- modify revert reasons in ERC721Badge for consistency

**0.5.0**
- (breaking change) modify the interface to add the `emitTransfer` function. Any upgradeable contract implementing the previous version won't by ugradeable. While this is not ideal, it is better for future usages, considering we still are in the proposal stage.

**0.4.1**
- remove the useless explicit dependency from ERC165

**0.4.0**
- change the pragma of an interface that was mistakenly set to 0.8.17. Now all of them are ^0.8.9 for consistency

**0.3.0**
- adding an ERC721Badge which is extended by the subordinate. BE CAREFUL, the change can break previous implementations

**0.2.0**
- remove the enumerable version because it is useless in the subordinates

**0.1.4** — _version not published_
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
