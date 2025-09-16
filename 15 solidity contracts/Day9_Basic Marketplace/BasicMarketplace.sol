//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicMarketplace {
    uint256 public itemCounter;
    address public owner;

    struct Item {
        uint256 id;
        address payable seller;
        string name;
        string description;
        uint256 price;
        bool isActive;
        bool isSold;
    }

    mapping(uint256 => Item) public items; // itemId =>Item details
    mapping(address => uint256[]) public sellerItems; //seller => array of item IDs
    mapping(address => uint256[]) public buyerPurchases; //buyer => purchased items IDs

    constructor() {
        itemCounter = 0;
        owner = msg.sender;
    }

    event ItemListed(uint256 id, address seller, string name, uint256 price);
    event ItemPurchased(
        uint256 id,
        address buyer,
        address seller,
        uint256 price
    );

    function listItem(
        string memory _name,
        string memory _description,
        uint256 _price
    ) public {
        require(_price > 0, "Price must be greater than zero");
        require(
            bytes(_name).length > 0 && bytes(_description).length > 0,
            "Name or Description cannot be empty"
        );
        itemCounter++;
        items[itemCounter] = Item({
            id: itemCounter,
            seller: payable(msg.sender),
            name: _name,
            description: _description,
            price: _price,
            isActive: true,
            isSold: false
        });
        sellerItems[msg.sender].push(itemCounter);
        emit ItemListed(itemCounter, msg.sender, _name, _price);
    }

    function buyItem(uint256 _itemId) public payable {
        Item storage item = items[_itemId];
        require(item.id == _itemId, "Item is not available");
        require(item.price == msg.value, "Price is not correct");
        require(item.isActive, "Item is not active");
        require(!item.isSold, "Item is sold already");
        require(msg.sender != item.seller, "Cannot buy your own item");

        item.isActive = false;
        item.isSold = true;
        buyerPurchases[msg.sender].push(_itemId);

        address receiver = item.seller;
        (bool sent, ) = receiver.call{value: msg.value}("");
        require(sent, "Failed to transfer amount");

        emit ItemPurchased(_itemId, msg.sender, item.seller, msg.value);
    }

    function getItem(uint256 _itemId) public view returns (Item memory) {
        return items[_itemId];
    }

    function getSellerItemsId(address _seller)
        public
        view
        returns (uint256[] memory)
    {
        return sellerItems[_seller];
    }

    function getBuyerPurchaseId(address _buyer)
        public
        view
        returns (uint256[] memory)
    {
        return buyerPurchases[_buyer];
    }

    function getSellerItems(address _seller)
        public
        view
        returns (Item[] memory)
    {
        uint256[] memory itemIds = sellerItems[_seller];
        Item[] memory sellerItemsList = new Item[](itemIds.length);

        for (uint256 i = 0; i < itemIds.length; i++) {
            sellerItemsList[i] = items[itemIds[i]];
        }

        return sellerItemsList;
    }

    function getSellerActiveItems(address _seller)
        public
        view
        returns (Item[] memory)
    {
        uint256[] memory itemIds = sellerItems[_seller];

        uint256 activeCount = 0;
        for (uint256 i = 0; i < itemIds.length; i++) {
            if (items[itemIds[i]].isActive && !items[itemIds[i]].isSold) {
                activeCount++;
            }
        }

        Item[] memory activeItems = new Item[](activeCount);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < itemIds.length; i++) {
            if (items[itemIds[i]].isActive && !items[itemIds[i]].isSold) {
                activeItems[currentIndex] = items[itemIds[i]];
                currentIndex++;
            }
        }

        return activeItems;
    }
}
