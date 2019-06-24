const FixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");
const Owner = artifacts.require("./Owner.sol");
const Exchange = artifacts.require("./Exchange.sol");

module.exports = function(deployer) {
  deployer.deploy(Owner);
  deployer.deploy(FixedSupplyToken);
  deployer.deploy(Exchange);
};
