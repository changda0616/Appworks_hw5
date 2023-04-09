// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract TodoListForAllSaveGas {
    struct Task {
        string name;
        bool completed;
    }

    mapping(address => Task[]) public taskBook;
    mapping(address => mapping(string => uint256)) private taskIndex;

    constructor() {}

    // 當有三個元素存在在 taskBook 中， create 一次需要的 gas 約 86751 gas, 增加 26288 gas
    function create(string calldata name) public {
        Task[] storage list = taskBook[msg.sender];
        list.push(Task({name: name, completed: false}));
        taskIndex[msg.sender][name] = list.length - 1;
    }

    // 當有三個元素存在在 taskBook 中， update 第三筆資料需要的 gas 約 56760 gas, 減少 12638 gas 
    // 第二次 update 第三筆資料需要的 gas 約 42602 gas, 與第一次相同減少 12638 gas Ｆ
    function update(string calldata name, bool completed) public {
        Task[] storage list = taskBook[msg.sender];
        uint256 index = taskIndex[msg.sender][name];
        list[index].completed = completed;
    }

    // 當有三個元素存在在 taskBook 中， get 一次需要的 gas 約 18814 gas
    function get(uint256 index) public view returns (string memory, bool) {
        Task[] memory list = taskBook[msg.sender];
        Task memory task = list[index];
        return (task.name, task.completed);
    }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}
