pragma solidity >=0.7.0 <0.9.0;

interface cETH {
    
    
    
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


interface UniswapRouter {
    function WETH() external pure returns (address);
    
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


contract SmartBankAccount {

    uint totalContractBalance = 0;
    
    //Ropsten CETH address
    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    
    // //    Rinkeby CETH address
    // address COMPOUND_CETH_ADDRESS = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    address UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    UniswapRouter uniswap = UniswapRouter(UNISWAP_ROUTER_ADDRESS);


    function getContractBalance() public view returns(uint){
        return totalContractBalance;
    }
    
    mapping(address => uint) balances;
  
    
    function addBalance() public payable {
        uint256 cEthOfContractBeforeMinting = ceth.balanceOf(address(this)); 
        
        // send ethers to mint()
        ceth.mint{value: msg.value}();
        
        uint256 cEthOfContractAfterMinting = ceth.balanceOf(address(this)); 
        
        uint cEthOfUser = cEthOfContractAfterMinting - cEthOfContractBeforeMinting; 
        balances[msg.sender] = cEthOfUser;
    }

    function addressER20(address erc20TokenSmartContractAddress) public{
        IERC20 erc20 = IERC20(erc20TokenSmartContractAddress);

        address token = erc20TokenSmartContractAddress;
        uint amountETHMin = 0; 
        address to = address(this);
        uint deadline = block.timestamp + (24 * 60 * 60);
        
        uint approvedAmountOfERC20Tokens = erc20.allowance(msg.sender, address(this));
        erc20.transferFrom(msg.sender, address(this), approvedAmountOfERC20Tokens);

        erc20.approve(UNISWAP_ROUTER_ADDRESS, approvedAmountOfERC20Tokens);
        
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        uniswap.swapExactTokensForETH(approvedAmountOfERC20Tokens, amountETHMin, path, to, deadline);
    }

    function getAllowanceERC20(address erc20TokenSmartContractAddress ) public view returns(uint){
        IERC20 erc20 = IERC20(erc20TokenSmartContractAddress);

        return erc20.allowance(msg.sender , address(this));
    }
    
    function getBalance(address userAddress) public view returns(uint){
  
        return ceth.balanceOf(userAddress)*ceth.exchangeRateStored()/1e18;
    }
    function getCethBalance(address userAddress) public view returns(uint256) {
        return balances[userAddress];
    }
    
    function getExchangeRate() public view returns(uint256){
        return ceth.exchangeRateStored();
    }
    
    function withdraw() public payable {
        ceth.redeem(balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }

   function approve(address erc20TokenSmartContractAddress ,address spender, uint amount) public returns (bool){
        IERC20 erc20 = IERC20(erc20TokenSmartContractAddress);
        erc20.approve(spender, amount);
        return true;
    }

 
  
    
}
