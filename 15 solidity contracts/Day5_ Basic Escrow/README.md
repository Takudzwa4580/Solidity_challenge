# BasicEscrow Smart Contract

A secure, decentralized escrow system built on Ethereum that facilitates trustless transactions between buyers and sellers with arbitration capabilities.

## Overview

This smart contract implements a comprehensive escrow system where:
- Buyers can deposit funds for transactions
- Sellers receive payment only upon delivery confirmation
- An independent arbiter resolves disputes between parties
- All transactions are transparent and enforceable on the blockchain
- Multiple states ensure proper workflow of the escrow process

## Contract Details

### Key Features

- **Three-Party System**: Buyer, seller, and arbiter structure
- **State Management**: Clear progression through escrow lifecycle
- **Dispute Resolution**: Arbiter can resolve conflicts and allocate funds
- **Security**: Multiple modifiers ensure proper access control
- **Transparency**: All actions and state changes are emitted as events

### States

The contract progresses through six distinct states:
1. **Created**: Escrow contract deployed but no funds deposited
2. **Funded**: Buyer has deposited funds into escrow
3. **Delivered**: Buyer has confirmed delivery (but not released funds yet)
4. **Disputed**: Either party has raised a dispute
5. **Released**: Funds have been released to the seller
6. **Refunded**: Funds have been returned to the buyer

## Roles

- **Buyer**: Initiates the escrow, deposits funds, confirms delivery
- **Seller**: Provides goods/services, receives payment upon completion
- **Arbiter**: Neutral third party who resolves disputes

## Functions

### Core Functions

#### `depositFunds()`
- **Description**: Buyer deposits funds into escrow
- **Requirements**: 
  - Only buyer can call
  - Must be in Created state
  - Must send ETH with transaction
- **Emits**: `FundsDeposited` event
- **Changes state**: Created → Funded

#### `confirmDelivery()`
- **Description**: Buyer confirms receipt of goods/services
- **Requirements**: 
  - Only buyer can call
  - Must be in Funded state
- **Emits**: `DeliveryConfirmed` event
- **Changes state**: Funded → Delivered

#### `releaseFunds()`
- **Description**: Buyer releases funds to seller
- **Requirements**: 
  - Only buyer can call
  - Must be in Delivered state
- **Emits**: `FundsReleased` event
- **Changes state**: Delivered → Released

#### `raiseDispute()`
- **Description**: Either party can raise a dispute
- **Requirements**: 
  - Only buyer or seller can call
  - Must be in Funded or Delivered state
- **Emits**: `DisputeRaised` event
- **Changes state**: Current → Disputed

#### `resolveDispute(address _victim)`
- **Description**: Arbiter resolves dispute in favor of one party
- **Parameters**: 
  - `_victim`: The party to receive the funds (buyer or seller)
- **Requirements**: 
  - Only arbiter can call
  - Must be in Disputed state
- **Emits**: `DisputeResolved` event
- **Changes state**: Disputed → Released (if seller) or Refunded (if buyer)

#### `refund(address payable _beneficiary)`
- **Description**: Arbiter manually refunds a specific party
- **Parameters**: 
  - `_beneficiary`: The party to receive the refund
- **Requirements**: 
  - Only arbiter can call
  - Must be in Disputed state
- **Emits**: `Refunded` event
- **Changes state**: Disputed → Refunded (if buyer) or Released (if seller)

#### `emergencyWithdraw()`
- **Description**: Arbiter can withdraw any leftover funds after resolution
- **Requirements**: 
  - Only arbiter can call
  - Must be in Released or Refunded state
  - Contract must have balance

### View Functions

#### `getContractBalance()`
- **Returns**: Current balance of the escrow contract

#### `getStatus()`
- **Returns**: Current status of the escrow

#### `getContractDetails()`
- **Returns**: All contract details (buyer, seller, arbiter, amount, status)

#### `isFinalized()`
- **Returns**: Boolean indicating if escrow is completed (Released or Refunded)

## Events

- `FundsDeposited(address indexed buyer, uint256 amount)`: Emitted when funds are deposited
- `DeliveryConfirmed(address indexed buyer, address indexed seller)`: Emitted when delivery is confirmed
- `FundsReleased(address indexed seller, uint256 amount)`: Emitted when funds are released to seller
- `DisputeRaised(address indexed buyer, address indexed seller)`: Emitted when dispute is raised
- `DisputeResolved(address indexed victim, uint256 amount)`: Emitted when dispute is resolved
- `Refunded(address indexed beneficiary, uint256 amount)`: Emitted when refund is processed

## Usage Flow

### Normal Flow
1. **Deploy** contract with buyer, seller, and arbiter addresses
2. **Buyer deposits** funds into escrow
3. **Seller delivers** goods/services (off-chain)
4. **Buyer confirms** delivery
5. **Buyer releases** funds to seller
6. **Escrow completes**

### Dispute Flow
1. **Deploy** contract with buyer, seller, and arbiter addresses
2. **Buyer deposits** funds into escrow
3. **Either party raises** dispute
4. **Arbiter resolves** dispute by allocating funds to appropriate party
5. **Escrow completes**

## Deployment Parameters

When deploying the contract, provide:
- `_buyer`: Address of the buyer
- `_seller`: Address of the seller  
- `_arbiter`: Address of the neutral arbiter

## Technical Specifications

- **Solidity Version**: ^0.8.19
- **License**: MIT
- **Network**: Ethereum Mainnet/Testnets
- **Security**: Uses checks-effects-interactions pattern

## Important Notes

- **Irreversible**: Once deployed, contract parameters cannot be changed
- **Arbiter Power**: The arbiter has significant control in dispute scenarios
- **Final States**: Once in Released or Refunded state, the escrow is complete
- **Gas Considerations**: All functions are optimized for gas efficiency
- **ETH Only**: Currently only supports ETH, not ERC20 tokens

## Security Features

- **Access Control**: Modifiers restrict functions to appropriate parties
- **State Validation**: Functions can only be called in appropriate states
- **Address Validation**: Checks for valid addresses and prevents conflicts
- **Funds Protection**: Secure transfer methods with success checks
- **No Reentrancy**: Uses built-in protection against reentrancy attacks

## Potential Improvements

1. **Token Support**: Add ERC20 token support alongside ETH
2. **Partial Releases**: Allow partial payments or refunds
3. **Time Locks**: Add expiration dates for disputes or deliveries
4. **Multiple Arbiters**: Implement multi-sig arbitration
5. **Fee Structure**: Add small fee for arbiter services
6. **Escrow Factory**: Create factory contract for multiple escrows

This contract provides a robust foundation for trustless transactions between parties who may not fully trust each other, with a neutral arbiter to resolve disputes when necessary.