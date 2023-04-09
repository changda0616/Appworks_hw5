// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract TodoListForAll {
    struct Task {
        string name;
        bool completed;
    }

    mapping(address => Task[]) public taskBook;

    constructor() {}

    // 當有三個元素存在在 taskBook 中， create 一次需要的 gas 約 60463 gas
    function create(string calldata name) public {
        Task[] storage list = taskBook[msg.sender];
        list.push(Task({name: name, completed: false}));
    }

    // 當有三個元素存在在 taskBook 中， update 第三筆資料需要的 gas 約 69398 gas，第二次 update 第三筆資料約需 55240 gas
    function update(string calldata name, bool completed) public {
        Task[] storage list = taskBook[msg.sender];
        for (uint256 i = 0; i < list.length; i++) {
            if (compareStrings(list[i].name, name)) {
                list[i].completed = completed;
            }
        }
    }

    // 當有三個元素存在在 taskBook 中，get 約需 18814 gas
    function get(uint256 index) public view returns (string memory, bool) {
        Task[] memory list = taskBook[msg.sender];
        Task memory task = list[index];
        return (task.name, task.completed);
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}
