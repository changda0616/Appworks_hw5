// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TodoListForOne {
    struct Task {
        string name;
        bool completed;
    }

    address public owner;
    Task[] private list;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function create(string calldata name) public onlyOwner {
        list.push(Task({name: name, completed: false}));
    }

    function update(string calldata name, bool completed) public onlyOwner {
        for (uint256 i = 0; i < list.length; i++) {
            if (compareStrings(list[i].name, name)) {
                list[i].completed = completed;
            }
        }
    }

    function get(uint256 index)
        public
        view
        onlyOwner
        returns (string memory, bool)
    {
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

    function kill() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}
