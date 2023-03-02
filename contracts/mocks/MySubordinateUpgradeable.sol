// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../ERC721SubordinateUpgradeable.sol";

contract MySubordinateUpgradeable is ERC721SubordinateUpgradeable, UUPSUpgradeable {
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize(address myTokenEnumerableUpgradeable) public initializer {
    __ERC721Subordinate_init("My Subordinate", "mSUBu", myTokenEnumerableUpgradeable);
    __UUPSUpgradeable_init();
  }

  function _authorizeUpgrade(address newImplementation) internal virtual override {}

  function getInterfaceId() public pure returns (bytes4) {
    return type(IERC721SubordinateUpgradeable).interfaceId;
  }
}
