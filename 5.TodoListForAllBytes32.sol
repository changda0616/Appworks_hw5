// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract TodoListForAllBytes32 {
    struct Task {
        bytes32 name;
        bool completed;
    }

    mapping(address => Task[]) public taskBook;
    mapping(address => mapping(bytes32 => uint256)) private taskIndex;

    constructor() {}

    // 當有三個元素存在在 taskBook 中， create 一次需要的 gas 約 85057 gas, 節省約 1694
    function create(bytes32 name) public {
        Task[] storage list = taskBook[msg.sender];
        list.push(Task({name: name, completed: false}));
        taskIndex[msg.sender][name] = list.length - 1;
    }

    // 當有三個元素存在在 taskBook 中， update 第三筆資料需要的 gas 約 56032 gas, 減少 1244 gas
    // 第二次 update 第三筆資料需要的 gas 約 41873 gas, 減少 729 gas
    function update(bytes32 name, bool completed) public {
        Task[] storage list = taskBook[msg.sender];
        uint256 index = taskIndex[msg.sender][name];
        list[index].completed = completed;
    }

    // 當有三個元素存在在 taskBook 中， get 一次需要的 gas 約 16547 gas, 減少 2267 gas
    function get(uint256 index) public view returns (bytes32, bool) {
        Task[] memory list = taskBook[msg.sender];
        Task memory task = list[index];
        return (task.name, task.completed);
    }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }

    function getBytes32String(string calldata input)
        external
        pure
        returns (bytes32)
    {
        return bytes32(abi.encodePacked(input));
    }

    function getStringFromByte32(bytes32 input)
        external
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(input));
    }
}
