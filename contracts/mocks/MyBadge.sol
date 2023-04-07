// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../ERC721Badge.sol";
import "../upgradeables/ERC721BadgeUpgradeable.sol";

contract MyBadge is ERC721Badge {
  constructor() ERC721Badge("MY Badge", "mBDG") {}

  function safeMint(address to, uint256 tokenId) public {
    _safeMint(to, tokenId);
  }

  function getInterfacesIds() public pure returns (bytes4, bytes4) {
    return (type(IERC721DefaultApprovable).interfaceId, type(IERC721DefaultLockable).interfaceId);
  }
}
