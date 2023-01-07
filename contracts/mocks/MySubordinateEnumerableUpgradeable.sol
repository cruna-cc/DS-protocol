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
}
