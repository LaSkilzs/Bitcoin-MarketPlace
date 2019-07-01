const FixedSupplyToken = artifacts.require("./fixedSupplyToken");

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

  it("second account should own no tokens", () => {
    let myTokenInstance;
    return FixedSupplyToken.deployed()
      .then(instance => {
        myTokenInstance = instance;
        return myTokenInstance.balanceOf(accounts[1]);
      })
      .then(balanceAccountOwner => {
        assert.equal(
          balanceAccountOwner.toNumber(),
          0,
          "Total Amount of tokens is owned by some otther address"
        );
      });
  });

  it("should send token correctly", () => {
    let token;

    let account_one = accounts[0];
    let account_two = accounts[1];

    let account_one_starting_balance;
    let account_two_starting_balance;

    let account_one_ending_balance;
    let account_two_ending_balance;

    let amount = 10;

    return FixedSupplyToken.deployed()
      .then(instance => {
        token = instance;
        return token.balanceOf.call(account_one);
      })
      .then(balance => {
        account_one_starting_balance = balance.toNumber();
        return token.balanceOf.call(account_two);
      })
      .then(balance => {
        account_two_starting_balance = balance.toNumber();
        return token.transfer(account_two, amount, { from: account_one });
      })
      .then(() => {
        return token.balanceOf.call(account_one);
      })
      .then(balance => {
        account_one_ending_balance = balance.toNumber();
        return token.balanceOf.call(account_two);
      })
      .then(balance => {
        account_two_ending_balance = balance.toNumber();
        assert.equal(
          account_one_ending_balance,
          account_one_starting_balance - amount,
          "Amount wasn't correctly taken from the sender"
        );
        assert.equal(
          account_two_ending_balance,
          account_two_starting_balance + amount,
          "Amount wasn't correctly sent to the receiver"
        );
      });
  });
});
