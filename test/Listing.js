const Asset = artifacts.require("Main.sol");

//require("chai").use(require("chai-as-promised")).should();

contract("Asset", (accounts) => {
  const acc = accounts[0];
  let contract;

  before(async () => {
    contract = await Asset.deployed();
  });

  describe("minting", async () => {
    it("Lists a new asset", async () => {
      await contract.mintNFT(25);
      await contract.createAuction(13479015, 13479300);
      await contract.listForAuction(0, 1);
      const res = await contract.Bid(0, {
        from: accounts[1],
        value: 1000000000000000000, //value in wei
      });
      console.log(res);
    });
  });
});
