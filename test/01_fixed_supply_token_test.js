var FixedSupplyToken = artifacts.require("./fixedSupplyToken");

contract("MyToken", function(accounts) {
  it("should verify that the first account has all the tokens", async () => {
    let _totalSupply;
    let myTokenInstance;

    return FixedSupplyToken.deployed()
      .then(instance => {
        myTokenInstance = instance;
        return myTokenInstance.totalSupply.call();
      })
      .then(totalSupply => {
        _totalSupply = totalSupply;
        return myTokenInstance.balanceOf(accounts[0]);
      })
      .then(balanceAccountOwner => {
        assert.equal(
          balanceAccountOwner.toNumber(),
          _totalSupply.toNumber(),
          "Total Amount of tokens is owned by owner"
        );
      });
  });
});
