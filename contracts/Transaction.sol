pragma solidity ^0.4.4;

contract Transaction {
  // custom types
  struct TransactionNeoPlace {
    uint id;
    address seller;
    address buyer;
    bytes16 itemId;
    bytes8 typeItem;
    bytes32 location;
    bytes16 pictureHash;
    bytes16 receiptHash;
    bytes32 comment;
    uint256 _price;
    bytes8 status;
  }

  // state variables
  mapping(uint => TransactionNeoPlace) public transactions;

  uint transactionCounter;

  // events
  event BuyItem(
    uint indexed _id,
    bytes16 indexed _itemId,
    address _seller,
    address _buyer,
    uint256 _price
  );

  // fetch the number of transactions in the contract
  function getNumberOfTransactions() public view returns (uint) {
    return transactionCounter;
  }

  // fetch and return all sales of the seller
  function getSales() public view returns (uint[]) {
    // prepare output array
    uint[] memory transactionIds = new uint[](transactionCounter);

    uint numberOfSales = 0;

    // iterate over transactions
    for(uint i = 1; i <= transactionCounter; i++) {
      // keep the ID if the transaction owns to the seller
      if(transactions[i].seller == msg.sender) {
        transactionIds[numberOfSales] = transactions[i].id;
        numberOfSales++;
      }
    }

    // copy the transactionIds array into a smaller getSales array
    uint[] memory sales = new uint[](numberOfSales);
    for(uint j = 0; j < numberOfSales; j++) {
      sales[j] = transactionIds[j];
    }
    return sales;
  }

  // fetch and return all purchases of the buyer
  function getPurchases() public view returns (uint[]) {
    // prepare output array
    uint[] memory transactionIds = new uint[](transactionCounter);

    uint numberOfBuy = 0;

    // iterate over transactions
    for(uint i = 1; i <= transactionCounter; i++) {
      // keep the ID if the transaction owns to the seller
      if(transactions[i].buyer == msg.sender) {
        transactionIds[numberOfBuy] = transactions[i].id;
        numberOfBuy++;
      }
    }

    // copy the transactionIds array into a smaller getBuy array
    uint[] memory buy = new uint[](numberOfBuy);
    for(uint j = 0; j < numberOfBuy; j++) {
      buy[j] = transactionIds[j];
    }
    return buy;
  }

  // new transaction / buy item
  function buyItem(address _seller, bytes16 _itemId, bytes8 _typeItem, bytes32 _location, bytes16 _pictureHash, bytes32 _comment, uint256 _price) payable public {
    // address not null
    require(_seller != 0x0);
    // seller don't allow to buy his own item
    require(msg.sender != _seller);

    require(_itemId.length > 0);
    require(_typeItem.length > 0);
    require(_location.length > 0);
    require(_pictureHash.length > 0);
    require(_comment.length > 0);

    require(msg.value == _price);

    _seller.transfer(msg.value);

    // new transaction
    transactionCounter++;

    // store the new transaction
    transactions[transactionCounter] = TransactionNeoPlace(
      transactionCounter,
      _seller,
      msg.sender,
      _itemId,
      _typeItem,
      _location,
      _pictureHash,
      "",
      _comment,
      _price,
      ""
    );

    // trigger the new transaction
    BuyItem(transactionCounter, _itemId, _seller, msg.sender, _price);
  }
  
}
