const Main = artifacts.require("DefiMain");
const Token = artifacts.require("VironToken");

module.exports = async function (deployer) {
  await deployer.deploy(Token);
  const token = await Token.deployed();

  await deployer.deploy(Main, token.address);
};
