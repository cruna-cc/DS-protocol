// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../ERC721Subordinate.sol";

contract MySubordinate is ERC721Subordinate {
  using Strings for uint256;

  constructor(address myToken) ERC721Subordinate("MY Subordinate", "mSUB", myToken) {}

  function getInterfaceId() public pure returns (bytes4) {
    return type(IERC721Subordinate).interfaceId;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    try IERC721(dominantToken()).ownerOf(tokenId) returns (address) {} catch (
      bytes memory /*lowLevelData*/
    ) {
      revert("ERC721Metadata: URI query for nonexistent token");
    }
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
  }

  function _baseURI() internal pure override returns (string memory) {
    return "https://img.everdragons2.com/e2gt/";
  }
}
