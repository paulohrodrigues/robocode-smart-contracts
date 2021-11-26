pragma solidity ^0.6.0;

interface IERC20 {
 
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokenSwap {
    IERC20 public tokenERC20;

    constructor(address _tokenERC20) public {
        tokenERC20 = IERC20(_tokenERC20);
    }
    
    function tokenTransfer(address addressGame) public payable {
        require(uint(tokenERC20.allowance(msg.sender, address(this))) <= uint(0), "Amount Error");
        uint256  amount = uint256(tokenERC20.allowance(msg.sender, address(this)));
        tokenERC20.transferFrom(msg.sender, addressGame, amount);
    }
}
