# ERC721Subordinate
An NFT which is subordinate to a primary NFT

## Why

In 2021, when we started Everdragons2, we had in mind of using the head of the dragons for a PFP token based on the Everdragons2 that you own. Here an example of a full dragon and just the head. 

![Dragon](https://github.com/ndujaLabs/ERC721Subordinate/blob/main/assets/Soolhoth.png)

![DragonPFP](https://github.com/ndujaLabs/ERC721Subordinate/blob/main/assets/Soolhoth_PFP.png)

The question was, _Should we allow people to transfer the PFP separately from the primary NFT?_ It didn't make much sense. At the same time, how to avoid that?

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

**Version 0.0.2 was not working with Solidity 0.8.17. Version 0.0.3 fixes the issue, but now it won't work with many previous version of Solidity. So, user ^0.8.17.** 

## Warnings

The contract produces a lot of warnings during the compilation because there are part of the extended contract which are not reachable, views that could become pure but that would change the standard interface, etc. 

A way to solve it is to take the original contracts by OpenZeppelin and put them into this repo, but that it is hard to maintain and potentially unsafe.

If you have a good idea to how to solve the issue feel free to submit a pull request.

For now, I believe that the warnings can be safely ignored.

## How it works

You initialize the subordinate token passing the address of the main token and the subordinate takes anything from that. Look at some example in mocks and the testing.

What makes the difference is the base token uri. Change that, and everything will work great.

## Implementations

[Everdragons2PGP](https://github.com/ndujaLabs/everdragons2-core/blob/version4-pfp/contracts/Everdragons2PFP.sol)

Feel free to make a PR to add your contracts.

## History

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
