# Basic Marketplace (Day 9)

A minimal on-chain marketplace where sellers can list items for a fixed price and buyers can purchase them with exact ETH.

## Overview
- **Contract**: `BasicMarketplace.sol`
- **Solidity**: ^0.8.19
- Tracks listed items, sellers' items, and buyers' purchases.
- Purchases transfer ETH directly to the seller.

## Data Structures
- `Item`:
  - `id`: incremental ID
  - `seller`: payable seller address
  - `name`, `description`: metadata
  - `price`: price in wei
  - `isActive`: listing active flag
  - `isSold`: sold flag

## Core Functions
- `listItem(string _name, string _description, uint256 _price)`
  - Lists a new item; requires non-empty name/description and price > 0.
  - Emits `ItemListed`.
- `buyItem(uint256 _itemId)` payable
  - Buys an active, unsold item with exact `msg.value == price`.
  - Marks item sold/inactive, records buyer purchase, and forwards ETH to seller.
  - Emits `ItemPurchased`.
- `getItem(uint256 _itemId)` view → `Item`
- `getSellerItemsId(address _seller)` view → `uint256[]`
- `getBuyerPurchaseId(address _buyer)` view → `uint256[]`
- `getSellerItems(address _seller)` view → `Item[]`
- `getSellerActiveItems(address _seller)` view → `Item[]`

## Events
- `ItemListed(uint256 id, address seller, string name, uint256 price)`
- `ItemPurchased(uint256 id, address buyer, address seller, uint256 price)`

## Usage (Remix/Hardhat)
1. Deploy `BasicMarketplace.sol`.
2. Seller calls `listItem(name, description, priceWei)`.
3. Buyer calls `buyItem(itemId)` sending exact ETH equal to `priceWei`.
4. Use getters to query items, seller listings, and buyer purchases.

### Notes
- Buyers must send the exact price; overpayments revert.
- Sellers cannot buy their own items.
- ETH is forwarded to the seller using `call`; execution reverts on failure.

## Example Flow
```text
Seller lists: listItem("Book", "Solidity 101", 0.1 ETH)
Buyer buys: buyItem(1) with 0.1 ETH
Item becomes sold and inactive; seller receives 0.1 ETH
```

## Possible Improvements
- Add listing cancellation and price update.
- Add reentrancy protection and escrow for safer settlement.
- Add pagination and events for updates.

## License
MIT
