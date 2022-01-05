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
    IERC20 public tokenObject;
    IERC20 public tokenCoin;
    uint256 private indexSales;
    uint256 private CONST_INDEX_NOT_FOUND = 10000000000000000000;

    struct TOKEN_OBJECT {
        uint256 tokenAmount;
        address owner;
        uint256 price;
    }
    
    mapping(uint256 => TOKEN_OBJECT ) public TokenObjectSales;
    
    uint[] public tokensIndex;

    constructor(address _tokenCoin, address _tokenObject) public {
        indexSales = 0;

        tokenCoin = IERC20(_tokenCoin);
        
        tokenObject = IERC20(_tokenObject);
    }
    
    function addSalesList(uint256 tokenAmount, uint256 price) public payable{
        require(uint(tokenObject.allowance(msg.sender, address(this))) >= uint(tokenAmount), "Error price");
        
        TokenObjectSales[indexSales] = TOKEN_OBJECT(tokenAmount, msg.sender, price);

        if(indexOf(indexSales) == CONST_INDEX_NOT_FOUND) {
            tokensIndex.push(indexSales);
        }

        indexSales++;
    }
    
    function buy(uint256 indexSale, uint256 amount) public payable {
        require(uint(tokenCoin.allowance(msg.sender, address(this))) >= uint(TokenObjectSales[indexSale].price), "Error price");
        
        require(uint(tokenObject.allowance(msg.sender, address(this))) >= uint(amount), "Error price");
        
        uint seller = (TokenObjectSales[indexSale].price * 98)/100;
        
        uint dev = (TokenObjectSales[indexSale].price * 2)/100;
        
        tokenCoin.transferFrom(msg.sender, TokenObjectSales[indexSale].owner, seller);
        
        tokenCoin.transferFrom(msg.sender, 0x105Bf69efe1Da6697e62bEA4193cFC3C8c35418b, dev);
        
        tokenObject.transferFrom(TokenObjectSales[indexSale].owner, msg.sender, amount);
        
        delete TokenObjectSales[indexSale];
        
        remove(indexOf(indexSale));
    }
    
    function remove(uint index) private {
        if (index >= tokensIndex.length) return;

        for (uint i = index; i<tokensIndex.length-1; i++){
            tokensIndex[i] = tokensIndex[i+1];
        }
        tokensIndex.pop();
    }

    function indexOf(uint256 tokenIndex) private view returns(uint){
        for(uint i=0; i<tokensIndex.length; i++){
            if(uint(tokensIndex[i])==uint(tokenIndex)){
                return i;
            }
        }
        return CONST_INDEX_NOT_FOUND;
    }

    // function removeListSaller(uint256 tokenId) public {
    //     require(msg.sender==tokenERC721.ownerOf(tokenId), "you don't own the nft");
    //     delete NFTSales[tokenId];
    //     remove(indexOf(tokenId));
    // }
    
    // function getByTokenId(uint256 tokenId) public view returns(uint256, address, uint256) {
    //     return (NFTSales[tokenId].tokenId, NFTSales[tokenId].owner, NFTSales[tokenId].price);
    // }
    
    // function getAllNFTs() public view returns(uint[] memory) {
    //     return tokensId;
    // }
    
}