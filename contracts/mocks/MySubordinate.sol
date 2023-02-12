// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../ERC721Subordinate.sol";

contract MySubordinate is ERC721Subordinate {
  constructor(address myToken) ERC721Subordinate("MY Subordinate", "mSUB", myToken) {}

  function getInterfaceId() public pure returns (bytes4) {
    return type(IERC721Subordinate).interfaceId;
  }
}
