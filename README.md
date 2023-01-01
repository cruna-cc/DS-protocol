# ERC721Subordinate
An NFT which is subordinate to a primary NFT

## Why

In 2021, when we started Everdragons2, we had in mind of using the head of the dragons for a PFP token based on the Everdragons2 that you own. Here an example of a full dragon and just the head. The question was, _Should we allow people to transfer the PFP separately from the primary NFT?_ It didn't make much sense. At the same time, how to avoid that?

ERC721Subordinate is the response. 

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

## Warnings

The contract produces a lot of warnings during the compilation because there are part of the extended contract which are not reachable, views that could become pure but that would change the standard interface, etc. 

A way to solve it is to take the original contracts by OpenZeppelin and put them into this repo, but that it is hard to maintain and potentially unsafe.

If you have a good idea to how to solve the issue feel free to submit a pull request.

For now, I believe that the warnings can be safely ignored.

## How it works

You initialize the subordinate token passing the address of the main token and the subordinate takes anything from that. Look at some example in mocks and the testing.

What makes the difference is the base token uri. Change that, and everything will work great.

## Implementations

Feel free to make a PR to add your contracts.

## History

**0.0.1**
- first version

## Copyright

(c) 2022, Francesco Sullo <francesco@sullo.co>

## License

MIT
