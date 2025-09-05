# Lottery Smart Contract

A decentralized lottery system built on Ethereum that allows users to participate in a fair and transparent raffle with automated winner selection and fund distribution.

## Overview

This smart contract implements a complete lottery system where:
- Users can purchase tickets at a fixed price
- The lottery runs for a specified duration or until all tickets are sold
- A random winner is selected through cryptographic methods
- Funds are automatically distributed (90% to winner, 10% to development wallet)
- All operations are transparent and verifiable on the blockchain

## Contract Details

### Key Features

- **Fixed Ticket Price**: Each ticket costs the same predetermined amount
- **Time-Based Lottery**: Lottery ends after specified duration or when all tickets sell out
- **Unique Participation**: Each address can purchase only one ticket
- **Random Winner Selection**: Uses blockchain properties for fair random number generation
- **Automated Distribution**: 90% of pool goes to winner, 10% to development
- **Status Tracking**: Clear state management through different lottery phases

### States

The contract progresses through four distinct states:
1. **Active**: Tickets can be purchased
2. **Ended**: Ticket sales are closed, ready for winner selection
3. **WinnerSelected**: Winner has been chosen, ready for fund distribution
4. **Completed**: Funds distributed, lottery concluded

## Functions

### Core Functions

#### `buyTicket()`
- **Description**: Purchase a lottery ticket
- **Requirements**: 
  - Lottery must be active
  - Send exact ticket price in ETH
  - Address hasn't purchased a ticket already
  - Lottery hasn't ended
  - Tickets still available
- **Emits**: `TicketPurchased` event

#### `endLottery()`
- **Description**: End the lottery (owner only)
- **Requirements**: 
  - Lottery must be active
  - Either all tickets sold or time expired
- **Changes state**: Active → Ended

#### `selectWinner()`
- **Description**: Randomly select a winner (owner only)
- **Requirements**: 
  - Lottery must be ended
  - At least one participant
- **Emits**: `WinnerSelected` event
- **Changes state**: Ended → WinnerSelected

#### `distributeFunds()`
- **Description**: Distribute prize pool (owner only)
- **Requirements**: 
  - Winner must be selected
- **Distribution**: 90% to winner, 10% to dev wallet
- **Emits**: `FundsDistributed` event
- **Changes state**: WinnerSelected → Completed

### View Functions

#### `getRemainingTime()`
- Returns time remaining until lottery ends (seconds)

#### `getLotteryStatus()`
- Returns current lottery status

#### `getParticipantsCount()`
- Returns number of participants

#### `getBalance()`
- Returns current contract balance

#### `getParticipants()`
- Returns array of all participant addresses

#### `hasParticipant(address _user)`
- Checks if specific address has purchased a ticket

## Events

- `TicketPurchased(address _buyer, uint256 _time)`: Emitted when ticket is bought
- `WinnerSelected(address _winner, uint256 _time)`: Emitted when winner is chosen
- `FundsDistributed(address _winner, uint256 _amount, address _devWallet, uint256 _devAmount, uint256 _time)`: Emitted when funds are distributed

## Deployment Parameters

When deploying the contract, provide:
- `_ticketPrice`: Price per ticket in wei
- `_raffleDuration`: Duration of lottery in seconds
- `_maxTickets`: Maximum number of tickets available
- `_ticketSalesLaunchTime`: Start time (Unix timestamp)
- `_devWallet`: Development wallet address for fees

## Security Features

- **Only owner functions**: Critical operations restricted to contract owner
- **State modifiers**: Functions can only be called in appropriate states
- **Input validation**: Comprehensive checks for all operations
- **Randomness generation**: Uses multiple blockchain properties for fairness
- **Funds protection**: No arbitrary withdrawal functions

## Usage Flow

1. **Deploy** contract with desired parameters
2. **Users buy tickets** during active period
3. **Owner ends lottery** when conditions met
4. **Owner selects winner** randomly
5. **Owner distributes funds** to winner and dev wallet
6. **Lottery completes**

## Technical Specifications

- **Solidity Version**: ^0.8.19
- **License**: MIT
- **Network**: Ethereum Mainnet/Testnets
- **Gas Optimization**: Uses efficient array management and state patterns

## Important Notes

- The contract uses `block.timestamp` and `block.prevrandao` for randomness
- Each address can only participate once
- Funds are automatically distributed according to preset percentages
- The contract must have sufficient gas for transactions
- Once completed, the lottery cannot be restarted

This contract provides a transparent, secure, and automated lottery system that eliminates traditional lottery operator risks and ensures fair participation for all users.