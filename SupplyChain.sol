//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

contract Ownable {
    address payable _owner;
    
    constructor() {
        _owner = payable(msg.sender);
    }
    
    modifier onlyOwner() {
        require(isOwner(), "You are not the owner of the contract");
        _;
    }
    
    function isOwner() public view returns(bool) {
        return (msg.sender == _owner);
    }
}

contract Item {
    //this contract will be responsible for handling the payments
    uint public priceInWei;
    uint public paidWei;
    uint public index;
    
    // `ItemManager` is a contract type that is defined below.
    // It is fine to reference it as long as it is not used
    // to create a new contract
    
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }
    
    function payItem() public payable {
        require(priceInWei == msg.value, "Only full payment allowed");
        require(paidWei == 0, "Item is paid already");
        paidWei += msg.value;
        (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "The transaction was not successful, canceling");
    }
    
    
}

contract ItemManager is Ownable {
    
    enum SupplyChainState{ Created, Paid, Delivered }
    
    struct S_Item {
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
        
        
    }
    
    mapping(uint => S_Item) public items;
    uint itemIndex;
    
    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);
    
    
    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _identifier;
        items[itemIndex]._itemPrice = _itemPrice;
        items[itemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(item));
        itemIndex++;
    }
    
    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex]._itemPrice == msg.value, "Only full payment accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item is further in the chain");
        
        items[_itemIndex]._state = SupplyChainState.Paid;
        
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
    
    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex]._state == SupplyChainState.Paid, "Item is further in the chain");
        
        items[_itemIndex]._state = SupplyChainState.Delivered;
        
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
}