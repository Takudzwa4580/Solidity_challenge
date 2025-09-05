# TokenStaking Smart Contract

A decentralized staking platform built on Ethereum that allows users to stake ERC20 tokens, earn rewards, and manage their staked assets with lock-up periods and penalty mechanisms.

## Overview

This smart contract implements a comprehensive staking system where:
- Users can stake ERC20 tokens for fixed lock-up periods
- Rewards are calculated based on staking duration and reward rate
- Early withdrawals incur penalties to discourage breaking lock-up periods
- All operations are transparent and enforceable on the blockchain

## Contract Details

### Key Features

- **ERC20 Token Support**: Works with any standard ERC20 token
- **Flexible Lock Periods**: Users can choose staking periods from 1 day to 365 days
- **Reward Calculation**: Real-time reward calculation based on staking duration
- **Penalty System**: Discourages early withdrawals with configurable penalties
- **Single Position**: Each address can only have one active stake at a time

## Roles

- **Stakers**: Users who deposit tokens to earn rewards
- **Token Contract**: The ERC20 token being staked (configurable at deployment)

## Staking Structure

Each stake contains:
- `amount`: Quantity of tokens staked
- `timestamp`: When the stake was created
- `lockPeriod`: Duration tokens are locked (in seconds)
- `lastRewardCalculation`: Last time rewards were calculated for this stake

## Functions

### Core Functions

#### `stake(uint256 _amount, uint256 _lockPeriod)`
- **Description**: Stake tokens for a specified lock period
- **Parameters**: 
  - `_amount`: Quantity of tokens to stake
  - `_lockPeriod`: Lock duration in seconds (1-365 days)
- **Requirements**: 
  - No active stake for the caller
  - Amount must be greater than 0
  - Lock period must be between 1 and 365 days
  - Token transfer must be approved
- **Emits**: `Staked` event

#### `withdraw()`
- **Description**: Withdraw staked tokens and rewards (minus penalty if applicable)
- **Requirements**: 
  - Caller must have an active stake
- **Calculation**:
  - Rewards based on staking duration and reward rate
  - Penalty applied if withdrawing before lock period ends
- **Emits**: `Withdrawn` event with amount, reward, and penalty details

### View Functions

#### `calculateReward(address _user)`
- **Returns**: Current reward amount for the specified user
- **Calculation**: `(amount * rewardRate * timeStaked) / (365 days * 10000)`

#### `isLocked(address _user)`
- **Returns**: Boolean indicating if user's stake is still locked
- **Calculation**: `current time < stake timestamp + lock period`

#### `stakes(address)`
- **Auto-generated**: Public mapping getter
- **Parameters**: Address to check
- **Returns**: Complete Stake structure for the specified address

## Configuration Parameters

Set during contract deployment:
- `_stakingToken`: Address of the ERC20 token to be staked
- `_rewardRate`: Annual reward rate (in basis points, e.g., 500 = 5%)
- `_penaltyRate`: Early withdrawal penalty rate (in basis points)

## Events

- `Staked(address indexed user, uint256 amount, uint256 lockPeriod)`: Emitted when tokens are staked
- `Withdrawn(address indexed user, uint256 amount, uint256 reward, uint256 penalty)`: Emitted when tokens are withdrawn

## Usage Flow

### Staking Process
1. **Approve**: User approves token transfer to staking contract
2. **Stake**: User calls `stake()` with amount and lock period
3. **Accrue**: Rewards accumulate over time
4. **Withdraw**: User calls `withdraw()` to claim tokens and rewards

### Example Participation
```javascript
// Approve tokens first
await tokenContract.approve(stakingContract.address, ethers.utils.parseEther("100"));

// Stake 100 tokens for 90 days
await stakingContract.stake(ethers.utils.parseEther("100"), 90 * 24 * 60 * 60);

// Check rewards
const rewards = await stakingContract.calculateReward(userAddress);

// Check if locked
const locked = await stakingContract.isLocked(userAddress);

// Withdraw (when lock period ends)
await stakingContract.withdraw();
```

## Technical Specifications

- **Solidity Version**: ^0.8.0
- **License**: MIT
- **Network**: Ethereum Mainnet/Testnets
- **Interface**: ERC20 token standard

## Important Notes

- **Single Stake**: Each address can only have one active stake at a time
- **Reward Calculation**: Rewards are calculated based on actual staking time
- **Penalty Application**: Early withdrawals incur percentage-based penalties
- **Token Management**: Users must approve token transfers before staking
- **Time-Based**: All calculations use blockchain timestamp

## Security Features

- **Reentrancy Protection**: Uses CEI pattern and built-in protections
- **Input Validation**: Validates amounts, lock periods, and user states
- **Access Control**: Modifiers prevent invalid operations
- **Fund Safety**: Secure token transfers with require checks

## Mathematical Formulas

### Reward Calculation
```
reward = (stakedAmount * rewardRate * timeStaked) / (365 days * 10000)
```

### Penalty Calculation
```
penalty = (stakedAmount * penaltyRate) / 10000
```

### Total Withdrawal Amount
```
totalAmount = stakedAmount + reward - penalty (if applicable)
```

## Potential Improvements

1. **Multiple Stakes**: Allow users to have multiple simultaneous stakes
2. **Tiered Rewards**: Different reward rates based on lock period or amount
3. **Compound Rewards**: Option to automatically reinvest rewards
4. **Governance**: Staking weight for governance voting
5. **Emergency Withdraw**: Function to withdraw with maximum penalty
6. **Reward Claim**: Separate function to claim rewards without unstaking

This contract provides a secure and flexible foundation for token staking programs, offering customizable lock periods, reward rates, and penalty structures to suit various DeFi applications.