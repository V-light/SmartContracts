pragma solidity >=0.7.0 <0.9.0;

contract MyErc20 {
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    string public name  = "MyErc20Token";
    string public symbol = "MYERC";

    mapping(uint => bool) blockMined;
    uint totalMinted = 1000000 * 1e8; 

    address deployer ;

    mapping(address =>uint) balances;
    mapping(address =>mapping(address=>uint)) allowances;

    constructor(){
        deployer = msg.sender;
        balances[deployer] = 1000000 *1e8;
    }
    
    function decimals() public pure  returns (uint8) {
        return 8;   
    }
    
    function totalSupply() public pure returns (uint256) {
        return 10000000*1e8; //10M
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];    
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender]>=0, "You do not have suffiecent balance");
        balances[_to] += _value;
        balances[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from]>=_value, "owner does not have enough money");
        require(allowances[_from][msg.sender]>= _value , "owner does not allow to transfer money");

        balances[_to]+= _value;
        balances[_from]-= _value;
        emit Transfer(_from, _to , _value);
        return true;    
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

 

    function mine() public returns(bool){
        if(blockMined[block.number]){
            return false;
        }
        if(block.number % 10 !=0){
            return false;
        }
        balances[msg.sender] += 10*1e8;
        totalMinted+= 10*1e8;
        blockMined[block.number] = true;
        return true;

    }

    function geBlockNumber() public view returns(uint) {
        return block.number;

    }

    function isMined(uint blockNumber) public view returns(bool) {
        return blockMined[blockNumber];

    }
    
    
}