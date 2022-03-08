// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract PiggyBank{
    event Deposit(uint amount);
    event Withdraw(uint amount);

    address payable public owner;
    receive() external payable{
        emit Deposit(msg.value);
    }
    constructor() {
        owner = payable(msg.sender);
    }

    function Balance () public view returns(uint){
        return address(this).balance;
    }

    function withdraw() external{
        require(msg.sender==owner, "Not authorized");
        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}