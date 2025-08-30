// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoContract {
    struct Task {
        uint256 id;
        string title;
        string description;
        bool completed;
        address owner;
    }
    Task[] public tasks;
    uint256 public taskCount;  

    event TaskAdded(uint256 id, string title, address owner);  
    event TaskDeleted(uint256 id, string title, address owner); 

    function addTask(string memory _title, string memory _description) public {
        taskCount++;  
        tasks.push(Task(taskCount, _title, _description, false, msg.sender)); 
        emit TaskAdded(taskCount, _title, msg.sender); 
    }

    function deleteTask(uint256 _id) public {
        require(tasks.length > 0, "Array is empty");
        require(_id > 0 && _id <= taskCount, "Invalid task ID");  
        
        uint256 taskIndex;
        bool found = false;
        for(uint256 i = 0; i < tasks.length; i++) {
            if(tasks[i].id == _id) {
                require(tasks[i].owner == msg.sender, "Not task owner");  
                taskIndex = i;
                found = true;
                break;
            }
        }
        require(found, "Task not found");
        
        string memory taskTitle = tasks[taskIndex].title;
        address taskOwner = tasks[taskIndex].owner;
        
        for(uint256 i = taskIndex; i < tasks.length - 1; i++) {
            tasks[i] = tasks[i + 1];
        }
        tasks.pop();
        
        emit TaskDeleted(_id, taskTitle, taskOwner);
    }

    function getTasks() public view returns(Task[] memory) {
        return tasks;
    }
    
    function viewTask(uint256 _id) public view returns(Task memory) {  
        require(_id > 0 && _id <= taskCount, "Invalid task ID");  
        
        for(uint256 i = 0; i < tasks.length; i++) {
            if(tasks[i].id == _id) {
                return tasks[i];
            }
        }
        revert("Task not found");  
    }
}