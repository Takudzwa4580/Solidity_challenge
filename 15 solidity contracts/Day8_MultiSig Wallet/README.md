# MultiSig Wallet (Day 8)

A simple multi-signature ETH wallet where an owner can add up to 4 sub-owners. Transactions require 3 confirmations in total (including the initiator's implicit confirmation) before funds can be transferred.

## Overview
- **Contract**: `MultiSig.sol`
- **Solidity**: ^0.8.19
- **Max sub-owners**: 4
- **Required confirmations**: 3
- The wallet can receive ETH via the `receive()` function.

## Key Concepts
- **Owners**: One primary `owner` set at deployment, plus up to 4 `subOwners`.
- **Transactions**: Created via `initiateTrxn`, confirmed via `confirmTrxn`, executed via `transferFunds` when confirmations ≥ 3.
- **Security**: Only the `owner` and `subOwners` can initiate/confirm/execute transactions.

## Core Functions
- `addSubOwners(address _subOwner)` (onlyOwner): Add a new sub-owner (max 4, no duplicates).
- `initiateTrxn(address _to, uint256 _amount)`: Create a transaction. Initiator counts as the first confirmation.
- `confirmTrxn(uint _id)`: Additional owners confirm a pending transaction.
- `transferFunds(uint256 _id)`: Executes a confirmed transaction; sends ETH to the target address.
- `getPendingTrxns()`: Returns an array of transactions that are not yet executed.
- `getTrxnWithID(uint _id)`: Returns a transaction by its ID.
- `getallOwners()`: Returns all owners (sub-owners + primary owner).
- `confCheck(uint _id, address _confirmer)`: Check if an address confirmed a given transaction.

## Events
- `SubOwnerAdded(address subOwner)`
- `TrxnInitiated(uint256 id, address to, address initiator, uint256 amount)`
- `TrxnConfirmed(uint256 id, address confirmer)`
- `TrxnCompleted(uint256 id, address to, address sender)`

## Modifiers
- `onlyOwner`: Restricts to the primary owner.
- `onlyOwnerAndSubOwners`: Restricts to the primary owner or any sub-owner.

## Usage (Remix or Hardhat)
1. Deploy `MultiSig.sol`. The deployer becomes `owner`.
2. Fund the contract by sending ETH directly to its address.
3. Call `addSubOwners` up to 4 times to register sub-owners.
4. Any owner/sub-owner can call `initiateTrxn(to, amount)` to propose a transfer.
5. Other owners/sub-owners call `confirmTrxn(id)` until confirmations reach 3.
6. Any owner/sub-owner calls `transferFunds(id)` to execute the transfer.

### Notes
- `initiateTrxn` sets `numConfirmations` to 1 for the initiator automatically.
- `confirmTrxn` cannot be called by the initiator for the same transaction and cannot be double-confirmed by the same address.
- `transferFunds` checks: not executed, confirmations ≥ 3, and contract balance sufficient.

## Example Flow
```text
Owner deploys contract
Owner adds SubOwner A, SubOwner B, SubOwner C
Owner funds contract with 1 ETH
SubOwner A calls initiateTrxn(Beneficiary, 0.5 ETH)  -> confirmations: 1
Owner calls confirmTrxn(1)                           -> confirmations: 2
SubOwner B calls confirmTrxn(1)                      -> confirmations: 3
Any owner/sub-owner calls transferFunds(1)           -> sends 0.5 ETH, marks executed
```

## Development
- Tested with Solidity ^0.8.19.
- Consider using Hardhat/Foundry for scripting and tests.

## Limitations & Improvements
- `getPendingTrxns` returns a fixed-size array with empty entries; could be optimized to return a compact list.
- No removal/replacement of sub-owners.
- ETH-only wallet (no ERC20 support in current version).

## License
MIT
