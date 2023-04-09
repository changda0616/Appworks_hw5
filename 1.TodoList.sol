// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TodoList {
    struct Task {
        string name;
        bool completed;
    }

    Task[] public list;

    function create(string calldata name) public {
        list.push(Task({name: name, completed: false}));
    }

    function update(string calldata name, bool completed) public {
        for (uint256 i = 0; i < list.length; i++) {
            if (compareStrings(list[i].name, name)) {
                list[i].completed = completed;
            }
        }
    }

    function get(uint256 index) public view returns (string memory, bool) {
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
        // selfdestruct will be deprecated, https://eips.ethereum.org/EIPS/eip-4758

        //  Can be used to hacked other contract to be forced accepting the remaining eth
        selfdestruct(payable(msg.sender));
    }
}
