const Asset = artifacts.require("Main.sol");

//require("chai").use(require("chai-as-promised")).should();

contract("Asset", (accounts) => {
  const acc = accounts[6];
  let contract;

  before(async () => {
    contract = await Asset.deployed();
  });

  describe("minting", async () => {
    it("Lists a new asset", async () => {
      const res0 = await contract.mint(25, { from: acc });
      console.log(res0);
      await contract.createAuction(257, 261);
      await contract.listForAuction(1, { value: 1000000000000000000 });
      await contract.Bid(1, {
        from: acc,
        value: 4000000000000000000, //value in wei
      });
      await contract.Bid(1, {
        from: acc,
        value: 3000000000000000000, //value in wei
      });
      const res = await contract.getAuctionResult();
      const res3 = await contract.bal(acc, 1);

      //   const res2 = await contract.getContractBalance();

      console.log(res3);
    });
  });
});
