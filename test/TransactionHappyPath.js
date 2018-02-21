var Transaction = artifacts.require("./Transaction.sol");

// test suite
contract('Transaction', function(accounts) {
  var transactiontInstance;
  var seller = accounts[1];
  var buyer = accounts[2];
  var itemId = "dfdf21df";
  var typeItem = "article";
  var location = "paris"
  var pictureHash = "QmePrSZk9Jo9L41itmRjRviXYKnocbVdGzbzaJyGR2kg9n";
  var receiptHash = "01fererf10";
  var comment = "send the article";
  var price = 2;
  var status= "bought";

  it("should be initialized with empty values", function() {
    return Transaction.deployed().then(function(instance) {
      transactiontInstance = instance;
      return transactiontInstance.getNumberOfTransactions();
    }).then(function(data) {
      assert.equal(data.toNumber(), 0, "number of transactions must be zero");
      return transactiontInstance.getSales();
    }).then(function(data) {
      assert.equal(data.length, 0, "there shoudn't be any sale");
      return transactiontInstance.getPurchases();
    }).then(function(data) {
      assert.equal(data.length, 0, "there shoudn't be any purchase");
    });
  });

  //buy the first article
  it("should buy article", function() {
    return Transaction.deployed().then(function(instance) {
      transactiontInstance = instance;
      // record balances of seller and buyer before the buy
      sellerBalanceBeforeBuy = web3.fromWei(web3.eth.getBalance(seller), "ether").toNumber();
      buyerBalanceBeforeBuy = web3.fromWei(web3.eth.getBalance(buyer), "ether").toNumber();
      return transactiontInstance.buyItem(seller,
        web3.fromAscii(itemId), web3.fromAscii(typeItem), web3.fromAscii(location), web3.fromAscii(pictureHash), web3.fromAscii(comment),  web3.toWei(price, "ether"),
        {from: buyer, value: web3.toWei(price, "ether")});
    }).then(function(receipt) {
      assert.equal(receipt.logs.length, 1, "one event should have been triggered");
      assert.equal(receipt.logs[0].event, "BuyItem", "event should be BuyItem");
      assert.equal(receipt.logs[0].args._id.toNumber(), 1, "transaction id must be 1")
      assert.equal(receipt.logs[0].args._seller, seller, "event seller must be " + seller);
      assert.equal(receipt.logs[0].args._buyer, buyer, "event buyer must be " + buyer);
      assert.equal(web3.toAscii(receipt.logs[0].args._itemId).replace(/\u0000/g, ''), itemId, "event item id must be " + itemId);
      assert.equal(receipt.logs[0].args._price.toNumber(), web3.toWei(price, "ether"), "event price must be " + price);

      // record balances of buyer and seller after the buy
      sellerBalanceAfterBuy = web3.fromWei(web3.eth.getBalance(seller), "ether").toNumber();
      buyerBalanceAfterBuy = web3.fromWei(web3.eth.getBalance(buyer), "ether").toNumber();

      // check the effect of buy on balances of buyer and seller, accounting for gas
      assert(sellerBalanceAfterBuy == sellerBalanceBeforeBuy, "seller should have waited " + price + " ETH");
      assert(buyerBalanceAfterBuy <= buyerBalanceBeforeBuy - price, "buyer should have spent " + price + " ETH");

      return transactiontInstance.unlockFunds(web3.fromAscii(itemId), {from: buyer});
    }).then(function(data) {

      sellerBalanceAfterBuy = web3.fromWei(web3.eth.getBalance(seller), "ether").toNumber();
      buyerBalanceAfterBuy = web3.fromWei(web3.eth.getBalance(buyer), "ether").toNumber();

      // check the effect of buy on balances of buyer and seller, accounting for gas
      assert(sellerBalanceAfterBuy == sellerBalanceBeforeBuy + price, "seller should have earned " + price + " ETH");
      assert(buyerBalanceAfterBuy <= buyerBalanceBeforeBuy - price, "buyer should have spent " + price + " ETH");

      return transactiontInstance.getSales({from: seller});
    }).then(function(data) {
      assert.equal(data.length, 1, "there should now be only 1 transactions");
      return transactiontInstance.getNumberOfTransactions();
    }).then(function(data) {
      assert.equal(data.toNumber(), 1, "there should still be 1 transaction in total")
    });
  });


});
