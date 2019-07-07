const exchange = artifacts.require("./Exchange");
const fixedSupplyToken = artifacts.require("./FixedSupplyToken");

contract("Exchange Basic Tests", function(accounts) {
  it("should be possible to add token", async () => {
    let myTokenInstance;
    let myExchangeInstance;

    return fixedSupplyToken
      .deployed()
      .then(instance => {
        myTokenInstance = instance;
        return instance;
      })
      .then(tokenInstance => {
        myTokenInstance = tokenInstance;
        return exchange.deployed();
      })
      .then(exchangeInstance => {
        myExchangeInstance = exchangeInstance;
        return myExchangeInstance.addToken("FIXED", myTokenInstance.address);
      })
      .then(txResult => {
        return myExchangeInstance.hasToken.call("FIXED");
      })
      .then(booleanHasToken => {
        assert.equal(booleanHasToken, true, "The Token was not added");
        return myExchangeInstance.hasToken.call("SOMETHING");
      })
      .then(booleanHasNotToken => {
        assert.equal(
          booleanHasNotToken,
          false,
          "A Token that doesn't exist was found."
        );
      });
  });

  it("should be possible to deposit and withdraw ether", async () => {
    let myExchangeInstance;
    let balanceBeforeTransaction = web3.eth.getBalance(accounts[0]);
    let balanceAfterDeposit;
    let balanceAfterWithdrawal;
    let gasUsed = 0;

    return exchange
      .deployed()
      .then(instance => {
        myExchangeInstance = instance;
        return myExchangeInstance.depositEther(
          {
            from: accounts[0],
            value: web3.utils.toWei("1", "ether")
          },
          0,
          "zrp"
        );
      })
      .then(txHash => {
        gasUsed =
          txHash.receipt.cumulativeGasUsed *
          web3.eth
            .getTransactioin(txHash.receipt.getTransactionHash)
            .gasPrice.toNumber();
        balanceAfterDeposit = web3.eth.getBalanceOf(accounts[0]);
        return myExchangeInstance.getEthBalanceInWei.call();
      })
      .then(balanceInWei => {
        assert.equal(
          balanceInWei.toNNumber(),
          web3.utils.toWei("1", "ether"),
          "There is one ether available"
        );
        assert.isAtLeast(
          balanceBeforeTransaction.toNumber() - balanceAfterDeposit.toNumber(),
          web3.utils.toWei("1", "ether"),
          "Balances of"
        );
        return myExchangeInstance.withdrawEther(web3.utils.toWei("1", "ether"));
      })
      .then(txHash => {
        balanceAfterWithdrawal = web3.eth.getBalance(accounts[0]);
        return myExchangeInstance.getEthBalanceInWei.call();
      })
      .then(balanceInWei => {
        assert.equal(
          balanceInWei.toNumber(),
          0,
          "There is no ether available anymore"
        );
        assert.isAtLeast(
          balanceAfterWithdrawal.toNumber(),
          balanceBeforeTransaction.toNumber() - gasUsed * 2,
          "There is one ether available"
        );
      });
  });

  it("should be possible to deposit token", async () => {
    let myExchangeInstance;
    let myTokenInstance;

    return fixedSupplyToken
      .deployed()
      .then(instance => {
        myTokenInstance = instance;
        return instance;
      })
      .then(tokenInstance => {
        myTokenInstance = tokenInstance;
        return exchange.deployed();
      })
      .then(exchangeInstance => {
        myExchangeInstance = exchangeInstance;
        return myTokenInstance.approve(myExchangeInstance.address, 2000);
      })
      .then(txResult => {
        return myExchangeInstance.depositToken("FIXED", 2000);
      })
      .then(txResult => {
        return myExchangeInstance.getBalance("FIXED");
      })
      .then(balanceToken => {
        console.log(balanceToken);
        assert.equal(
          balanceToken,
          2000,
          "There should be 2000 tokens for the address"
        );
      });
  });

  it("should be possible to withdraw token", async () => {
    let myExchangeInstance;
    let myTokenInstance;
    let balanceTokenInExchangeBeforeWithdrawal;
    let balanceTokenInTokenBeforeWithdrawal;
    let balanceTokenInExchangeAfterWithdrawal;
    let balanceTokenInTokenAfterWithdrawal;

    return fixedSupplyToken
      .deployed()
      .then(instance => {
        myTokenInstance = instance;
        return instance;
      })
      .then(tokenInstance => {
        myTokenInstance = tokenInstance;
        return exchange.deployed();
      })
      .then(exchangeInstance => {
        myExchangeInstance = exchangeInstance;
        return myExchangeInstance.getBalance.call("FIXED");
      })
      .then(balanceExchange => {
        balanceTokenInExchangeBeforeWithdrawal = balanceExchange.toNumber();
        return myTokenInstance.balanceOf.call(accounts[0]);
      })
      .then(balanceToken => {
        balanceTokenInTokenBeforeWithdrawal = balanceToken.toNumber();
        return myExchangeInstance.withdrawToken(
          "FIXED",
          balanceTokenInExchangeBeforeWithdrawal
        );
      })
      .then(txResult => {
        return myExchangeInstance.getBalance.call("FIXED");
      })
      .then(balanceExchange => {
        balanceTokenInExchangeAfterWithdrawal = balanceExchange.toNumber();
        console.log("balance", balanceTokenInExchangeAfterWithdrawal);
        return myTokenInstance.balanceOf.call(accounts[0]);
      })
      .then(balanceToken => {
        balanceTokenInTokenAfterWithdrawal = balanceToken.toNumber();
        assert.equal(
          balanceTokenInExchangeAfterWithdrawal,
          0,
          "There should be 0 tokens left in the exchange"
        );
        // assert.equal(
        //   balanceTokenInExchangeAfterWithdrawal,
        //   balanceTokenInExchangeBeforeWithdrawal +
        //     balanceTokenInTokenBeforeWithdrawal,
        //   "There sshould be 0 tokens left in the  exchange"
        // );
      });
  });
});
