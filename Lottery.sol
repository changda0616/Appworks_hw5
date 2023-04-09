// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract LockableLottery {
    address public lockOwner;
    bool public isLock;

    event LotteryLocked();
    event LotteryUnLocked();

    constructor(address addr) {
        lockOwner = addr;
    }

    // Both this contract and its' derived contract can call lock/unlock
    function _lockTheLottery() internal {
        require(msg.sender == lockOwner, "Only the owner can lock");
        isLock = true;
        emit LotteryLocked();
    }

    function _unlockTheLottery() internal {
        require(msg.sender == lockOwner, "Only the owner can unlock");
        isLock = false;
        emit LotteryUnLocked();
    }
}

contract Lottery is LockableLottery {
    uint256 private randomNonce;
    address[] public participants;
    address public owner;

    event WinnerSelected(string message, address winner, address lockOwner);

    constructor(address _lockableAddr) LockableLottery(_lockableAddr) {
        owner = msg.sender;
    }

    // Only external sources except this contract account can enter this game
    function enter() external payable {
        require(
            msg.value >= 1 ether,
            "Must send above 1 Ether to enter the pool"
        );
        require(
            !isLock,
            "The current batch is locked, please wait for the next one"
        );
        participants.push(msg.sender);
    }

    // Everyone can call this selectWinner function
    function selectWinner() public returns (address) {
        require(msg.sender == owner, "Only the owner can select");
        require(
            isLock,
            "We can only reveal the winner after the lottery has been locked"
        );
        address winner = participants[_random() % participants.length];

        // Send money to the winner, use call to prevent out-of-gas issue
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Lotter transfer failed");
        emit WinnerSelected(
            "The winner of lottery has been selected, ask lock owner to unluck the lottery",
            winner,
            lockOwner
        );
        // Reset the participants' pool and open the entrance
        participants = new address[](0);
        return winner;
    }

    // Only this contract need to call the function to generate a random number
    function _random() private returns (uint256) {
        randomNonce += 1;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, randomNonce, msg.sender)
                )
            );
    }

    // Only this contract can call this function to know the current prize,
    // and because it is not mutating any state of this countract,
    // so we can place a view modifer
    function _getCurrentPrize() private view returns (uint256) {
        return address(this).balance;
    }

    // Only external resources can lock/unlock the lottery
    function lockLottery() external {
        require(
            _getCurrentPrize() >= 3 ether,
            "The min requirement to lock the lottery is 3 Eth"
        );
        _lockTheLottery();
    }

    function unlockTheLottery() external {
        _unlockTheLottery();
    }
}
