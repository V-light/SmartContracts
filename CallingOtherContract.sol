// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CallTestContract{
    function setX(TestContract _test, uint _x) public {
        _test.setX(_x);
    }

    function getX(TestContract _test) public view returns (uint x){
        x =_test.getX();
    }

    function setXandReceiveEther(address _test, uint _x) payable public{
        TestContract(_test).setXandReceiveEther{value: msg.value}(_x);
    }

    function getXandValue(address _test) public view returns(uint x, uint value){
        (x, value) = TestContract(_test).getXandValue();
    }
}

contract TestContract{
    uint public x;
    uint public value;

    function setX(uint _x) external {
        x = _x;
    }

    function getX() external view returns(uint){
        return x;
    }

    function setXandReceiveEther(uint _x)  external payable {
        x = _x;
        value = msg.value;
    }
    function getXandValue() external view returns(uint  , uint){
        return(x, value);
    }

}