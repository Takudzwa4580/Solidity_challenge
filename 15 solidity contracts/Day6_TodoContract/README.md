# Todo Smart Contract

A decentralized todo list application built on Ethereum that allows users to create, manage, and delete their personal tasks on the blockchain.

## Overview

This smart contract implements a simple yet effective todo list system where:
- Users can create tasks with titles and descriptions
- Each task is owned by the creator's address
- Users can view their tasks and check completion status
- Tasks can be deleted by their owners
- All operations are transparent and permanently stored on the blockchain

## Contract Details

### Key Features

- **Task Management**: Create, view, and delete tasks
- **Ownership Control**: Each task is owned by the creator
- **Completion Tracking**: Tasks have a boolean completed status
- **Transparent Operations**: All actions are recorded on-chain
- **Gas Efficient**: Optimized array management for cost-effective operations

### Task Structure

Each task contains:
- `id`: Unique identifier for the task
- `title`: Short description of the task
- `description`: Detailed explanation of the task
- `completed`: Boolean indicating completion status
- `owner`: Ethereum address of the task creator

## Functions

### Core Functions

#### `addTask(string memory _title, string memory _description)`
- **Description**: Create a new todo task
- **Parameters**: 
  - `_title`: Short title for the task
  - `_description`: Detailed description of the task
- **Emits**: `TaskAdded` event with task ID, title, and owner

#### `deleteTask(uint256 _id)`
- **Description**: Remove a task from the list
- **Parameters**: 
  - `_id`: ID of the task to delete
- **Requirements**: 
  - Task must exist
  - Caller must be the task owner
- **Emits**: `TaskDeleted` event with task ID, title, and owner

### View Functions

#### `getTasks()`
- **Returns**: Array of all tasks in the contract
- **Note**: This returns all users' tasks (consider gas costs for large arrays)

#### `viewTask(uint256 _id)`
- **Parameters**: `_id` - ID of the task to view
- **Returns**: Complete Task structure for the requested ID
- **Requirements**: Task must exist

#### `tasks(uint256 index)`
- **Auto-generated**: Public array getter (provided by Solidity)
- **Parameters**: `index` - Position in the tasks array
- **Returns**: Task structure at the specified index

#### `taskCount()`
- **Returns**: Total number of tasks created (including deleted ones)
- **Note**: This count never decreases, even when tasks are deleted

## Events

- `TaskAdded(uint256 id, string title, address owner)`: Emitted when a new task is created
- `TaskDeleted(uint256 id, string title, address owner)`: Emitted when a task is deleted

## Usage Examples

### Creating a Task
```javascript
// Call the addTask function with title and description
await todoContract.addTask("Buy groceries", "Milk, eggs, bread, and fruits");
```

### Viewing Tasks
```javascript
// Get all tasks
const allTasks = await todoContract.getTasks();

// View a specific task
const task = await todoContract.viewTask(1);
```

### Deleting a Task
```javascript
// Delete task with ID 1
await todoContract.deleteTask(1);
```

## Technical Specifications

- **Solidity Version**: ^0.8.19
- **License**: MIT
- **Network**: Ethereum Mainnet/Testnets
- **Storage**: Uses array-based storage for tasks

## Important Notes

- **Task IDs**: Are sequential and never reused, even after deletion
- **Gas Considerations**: 
  - Looping through all tasks with `getTasks()` can be expensive with many tasks
  - Deleting tasks requires shifting array elements, which has O(n) gas cost
- **Privacy**: All tasks are publicly visible on the blockchain
- **Permanence**: While tasks can be deleted from the contract, they remain visible in blockchain history

## Security Features

- **Ownership Checks**: Only task owners can delete their tasks
- **Input Validation**: Checks for valid task IDs before operations
- **Array Bounds**: Prevents operations on empty arrays

## Potential Improvements

1. **Pagination**: Add pagination to `getTasks()` to avoid high gas costs
2. **User-specific Retrieval**: Add function to get only caller's tasks
3. **Task Updates**: Add function to modify task content or completion status
4. **Events**: Add events for task completion status changes
5. **Access Control**: Add admin functions for emergency stops

This contract provides a basic but functional todo list system on the blockchain, demonstrating how to manage user-specific data in a decentralized environment while maintaining ownership and control over personal data.