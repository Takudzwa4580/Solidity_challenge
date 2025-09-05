# BasicToken Smart Contract

A simple ERC20-like token implementation built on Ethereum that provides basic token functionality including transfers, approvals, and allowance management.

## Overview

This smart contract implements a fundamental token standard that allows:
- Creation of custom tokens with configurable parameters
- Token transfers between addresses
- Approval mechanism for delegated spending
- Basic token economics with fixed supply

## Contract Details

### Key Features

- **Configurable Token**: Name, symbol, and total supply can be set during deployment
- **Standard Decimals**: Uses 18 decimals (standard for most Ethereum tokens)
- **Balance Tracking**: Maintains balances for all token holders
- **Allowance System**: Supports approved spending limits between addresses
- **Event Emission**: Complies with standard token events for blockchain transparency

## Token Information

### Configurable Parameters (set at deployment)
- **Name**: The full name of the token (e.g., "MyToken")
- **Symbol**: The ticker symbol (e.g., "MTK")  
- **Total Supply**: The initial token supply minted to deployer

### Fixed Parameters
- **Decimals**: 18 (standard ERC20 decimal places)
- **Initial Distribution**: Entire supply minted to contract deployer

## Functions

### Core Functions

#### `transfer(address _to, uint256 _value)`
- **Description**: Transfer tokens to another address
- **Parameters**: 
  - `_to`: Recipient address
  - `_value`: Amount of tokens to transfer
- **Requirements**: 
  - Sufficient balance in sender's account
  - Valid recipient address (not zero address)
- **Emits**: `Transfer` event
- **Returns**: `true` if successful

#### `approve(address _spender, uint256 _value)`
- **Description**: Approve another address to spend tokens on your behalf
- **Parameters**: 
  - `_spender`: Address to approve for spending
  - `_value`: Maximum amount that can be spent
- **Emits**: `Approval` event
- **Returns**: `true` if successful

#### `transferFrom(address _from, address _to, uint256 _value)`
- **Description**: Transfer tokens on behalf of another address
- **Parameters**: 
  - `_from`: Address to transfer from (must have approved caller)
  - `_to`: Recipient address
  - `_value`: Amount of tokens to transfer
- **Requirements**: 
  - Sufficient balance in `_from` account
  - Sufficient allowance approved for caller
  - Valid recipient address
- **Emits**: `Transfer` event
- **Returns**: `true` if successful

### View Functions

#### `balanceOf(address)`
- **Returns**: Token balance of the specified address

#### `allowance(address owner, address spender)`
- **Returns**: Remaining allowance that spender can transfer from owner

#### Token Metadata
- `name()`: Returns token name
- `symbol()`: Returns token symbol  
- `decimals()`: Returns number of decimals (18)
- `totalSupply()`: Returns total token supply

## Events

- `Transfer(address indexed from, address indexed to, uint256 value)`: Emitted when tokens are transferred
- `Approval(address indexed owner, address indexed spender, uint256 value)`: Emitted when spending approval is granted

## Deployment

### Constructor Parameters
When deploying the contract, provide:
- `_name`: string - The name of your token
- `_symbol`: string - The symbol/ticker of your token  
- `_totalSupply`: uint256 - The initial total supply of tokens

### Example Deployment
```javascript
// Deploy with name "MyToken", symbol "MTK", and 10,000 total supply
const token = await BasicToken.deploy("MyToken", "MTK", 10000);
```

## Usage Examples

### Basic Transfer
```javascript
// Transfer 100 tokens to another address
await token.transfer(recipientAddress, 100);

// Check balance
const balance = await token.balanceOf(userAddress);
```

### Approved Transfers
```javascript
// Approve another address to spend up to 500 tokens
await token.approve(spenderAddress, 500);

// Check allowance
const allowed = await token.allowance(ownerAddress, spenderAddress);

// Spender transfers from owner's account
await token.transferFrom(ownerAddress, recipientAddress, 200);
```

## Technical Specifications

- **Solidity Version**: ^0.8.0
- **License**: MIT
- **Network**: Ethereum Mainnet/Testnets
- **Standard**: ERC20-like (basic implementation)

## Important Notes

- **Fixed Supply**: Total supply is set at deployment and cannot be changed
- **No Mint/Burn**: This implementation doesn't include minting or burning functions
- **Initial Distribution**: Deployer receives the entire initial supply
- **Basic Features**: This is a minimal implementation without advanced ERC20 features

## Security Considerations

- **Input Validation**: Includes checks for valid addresses and sufficient balances
- **Overflow Protection**: Uses Solidity 0.8.0+ built-in overflow checks
- **No Reentrancy**: Simple functions without external calls that could cause reentrancy

## Differences from Full ERC20 Standard

This implementation includes the core ERC20 functions but lacks:
- Optional metadata methods (`name()`, `symbol()`, `decimals()` are implemented)
- Advanced features like minting, burning, or pausing
- Permit functionality (EIP-2612 for gasless approvals)
- Snapshots or voting mechanisms

## Potential Enhancements

1. **Mint Function**: Add controlled minting capability
2. **Burn Function**: Allow token burning to reduce supply
3. **Pausable**: Add emergency stop functionality
4. **Ownable**: Restrict certain functions to contract owner
5. **Blacklist**: Add address blacklisting capability
6. **Upgradable**: Make contract upgradable using proxy pattern

This contract provides a simple foundation for creating custom tokens on Ethereum, suitable for learning purposes or basic token requirements without the complexity of a full ERC20 implementation.