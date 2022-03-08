// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MultiSig{
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner , uint indexed txId);
    event Execute(uint indexed txId);

    struct Transaction {
        address to;
        uint  value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint public required;

    Transaction[] public transactions;
    mapping(uint =>mapping(address=>bool)) public approved;

    constructor(address[]  memory _owners , uint _required ){
        require(_owners.length >0 , "Owner length should be greater than zero");
        require(_required >0 && _required< _owners.length, "Required is not valid");

        for(uint i ; i<_owners.length; i++){
            require(_owners[i]!= address(0), "owner should not be zero");
            require(!isOwner[_owners[i]]);
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;

        }

        required = _required;
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }


    modifier onlyowner(){
        require(isOwner[msg.sender], "you are not owner");
        _;
    }

    modifier isExists(uint _txId){
        require(_txId< transactions.length, "transaction is not exist in contract");
        _;
    }
    modifier notApproved(uint _txId){
        require(approved[_txId][msg.sender]==false, "transaction is already approved");
        _;
    }
    modifier notExecuted(uint _txId){
        require(transactions[_txId].executed ==false, "transactions is already executed");
        _;
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyowner{
        transactions.push(Transaction({
            to: _to,
            value : _value,
            data : _data,
            executed: false
        }));

        emit Submit(transactions.length-1);
    }

    function approve(uint _txId) onlyowner isExists(_txId) notApproved(_txId) notExecuted(_txId) public{
        approved[_txId][msg.sender] =true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovelCount(uint _txId) private view returns(uint count){
        for(uint i ; i<owners.length; i++){
            if(approved[_txId][owners[i]]){
                count+=1;
            }
        }
    }

    function execute(uint _txId) external isExists(_txId) notExecuted(_txId) {
        uint count = _getApprovelCount(_txId);
        require(count>= required, "Transaction is not approved by required ownser");
        Transaction storage transaction = transactions[_txId];
        (bool success ,)= transaction.to.call{value : transaction.value}(transaction.data);

        require(success, "tx falied");
        emit Execute(_txId);
    }

    function revoke(uint _txId)  external onlyowner isExists(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender] , "transaction is not approved");
        approved[_txId][msg.sender] = false;
        emit  Revoke( msg.sender , _txId);
    }
    




}