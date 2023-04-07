// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../ERC721Badge.sol";

contract MySoulbound is ERC721Badge {
  constructor() ERC721Badge("My Soulbound Token", "MST") {
    emit DefaultApprovable(false);
    emit DefaultLocked(true);
  }
}
