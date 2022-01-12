const Mint = artifacts.require("NFT");

contract("Minting", (accounts) => {
  const acc = accounts[1];
  let contract;

  describe("minting", async () => {
    it("Mints a new asset", async () => {
      const contract = await Mint.deployed();
      const result = await contract.mint(1, 2, "45", "1234", "asas");
      console.log(result.logs[0].args);
    });
  });
});
