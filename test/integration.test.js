const {expect} = require("chai");
const {deployContractUpgradeable, deployContract, number} = require("./helpers");

describe("Integration", function () {
  let myToken;
  let myTokenEnumerable;

  let subordinate;
  let subordinateUpgradeable;

  let owner, holder1, holder2, holder3;

  before(async function () {
    [owner, holder1, holder2, holder3] = await ethers.getSigners();
  });

  beforeEach(async function () {
    myToken = await deployContract("MyToken");

    expect(await myToken.getInterfacesIds()).deep.equal(["0x48b041fd", "0x431694c0"]);

    subordinate = await deployContract("MySubordinate", myToken.address);
    await myToken.addSubordinate(subordinate.address);

    await myToken.safeMint(holder1.address, 1);
    await myToken.safeMint(holder1.address, 2);
    await expect(myToken.safeMint(holder1.address, 3))
      .emit(myToken, "Transfer")
      .withArgs(ethers.constants.AddressZero, holder1.address, 3)
      .emit(subordinate, "Transfer")
      .withArgs(ethers.constants.AddressZero, holder1.address, 3);

    myTokenEnumerable = await deployContract("MyTokenEnumerable");

    await myTokenEnumerable.safeMint(holder1.address, 1);
    await myTokenEnumerable.safeMint(holder1.address, 3);
    await myTokenEnumerable.safeMint(holder1.address, 2);

    subordinateUpgradeable = await deployContractUpgradeable("MySubordinateUpgradeable", [myTokenEnumerable.address]);
  });

  it("should verify the flow for ERC721Subordinate", async function () {
    expect(await myToken.balanceOf(holder1.address)).equal(3);
    expect(await subordinate.balanceOf(holder1.address)).equal(3);

    expect(await myToken.ownerOf(1)).equal(holder1.address);
    expect(await subordinate.ownerOf(1)).equal(holder1.address);

    expect(await myToken.balanceOf(holder2.address)).equal(0);
    expect(await subordinate.balanceOf(holder2.address)).equal(0);

    await myToken.connect(holder1)["safeTransferFrom(address,address,uint256)"](holder1.address, holder2.address, 1);

    expect(await myToken.balanceOf(holder1.address)).equal(2);
    expect(await subordinate.balanceOf(holder1.address)).equal(2);

    expect(await myToken.ownerOf(1)).equal(holder2.address);
    expect(await subordinate.ownerOf(1)).equal(holder2.address);

    expect(await myToken.balanceOf(holder2.address)).equal(1);
    expect(await subordinate.balanceOf(holder2.address)).equal(1);

    expect(await subordinate.getInterfaceId()).equal("0x431694c0");
  });

  it("should verify the flow for ERC721EnumerableSubordinateUpgradeable", async function () {
    expect(await myTokenEnumerable.balanceOf(holder1.address)).equal(3);
    expect(await subordinateUpgradeable.balanceOf(holder1.address)).equal(3);

    expect(await myTokenEnumerable.ownerOf(1)).equal(holder1.address);
    expect(await subordinateUpgradeable.ownerOf(1)).equal(holder1.address);

    expect(await myTokenEnumerable.balanceOf(holder2.address)).equal(0);
    expect(await subordinateUpgradeable.balanceOf(holder2.address)).equal(0);

    expect(await myTokenEnumerable.tokenOfOwnerByIndex(holder1.address, 1)).equal(3);
    try {
      await subordinateUpgradeable.tokenOfOwnerByIndex(holder1.address, 1);
    } catch (e) {
      expect(e.message).equal("subordinateUpgradeable.tokenOfOwnerByIndex is not a function");
    }

    expect(await myTokenEnumerable.tokenByIndex(1)).equal(3);
    try {
      await subordinateUpgradeable.tokenByIndex(1);
    } catch (e) {
      expect(e.message).equal("subordinateUpgradeable.tokenByIndex is not a function");
    }

    await myTokenEnumerable.connect(holder1)["safeTransferFrom(address,address,uint256)"](holder1.address, holder2.address, 1);

    expect(await myTokenEnumerable.balanceOf(holder1.address)).equal(2);
    expect(await subordinateUpgradeable.balanceOf(holder1.address)).equal(2);

    expect(await myTokenEnumerable.ownerOf(1)).equal(holder2.address);
    expect(await subordinateUpgradeable.ownerOf(1)).equal(holder2.address);

    expect(await myTokenEnumerable.balanceOf(holder2.address)).equal(1);
    expect(await subordinateUpgradeable.balanceOf(holder2.address)).equal(1);

    expect(await subordinateUpgradeable.getInterfaceId()).equal("0x431694c0");
  });
});
