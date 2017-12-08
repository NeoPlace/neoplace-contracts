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

  }
}
