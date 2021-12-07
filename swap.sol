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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract TokenSwap {
    IERC20 public tokenERC20;
    IERC721 public tokenERC721;

    struct NFT {
        uint256 tokenId;
        address owner;
        uint256 price;
    }
    
    mapping(uint256 => NFT ) public NFTSales;
    
    uint[] public tokensId;

    constructor(address _tokenERC20, address _tokenERC721) public {
        tokenERC20 = IERC20(_tokenERC20);
        tokenERC721 = IERC721(_tokenERC721);
    }
    
    function addSalesList(uint256 tokenId, uint256 price) public payable{
        require(msg.sender==tokenERC721.ownerOf(tokenId), "you don't own the nft");
        require(address(this)==tokenERC721.getApproved(tokenId), "contract is not allowed");
        
        NFTSales[tokenId] = NFT(tokenId, msg.sender, price);
        if(indexOf(tokenId) == 1000000000) {
            tokensId.push(tokenId);
        }
    }
    
    function buy(uint256 tokenId) public payable {
        require(uint(tokenERC20.allowance(msg.sender, address(this))) >= uint(NFTSales[tokenId].price), "Error price");
        require(address(this)==tokenERC721.getApproved(tokenId), "contract is not allowed");
        
        uint seller = (NFTSales[tokenId].price * 98)/100;
        uint dev = (NFTSales[tokenId].price * 2)/100;
        
        tokenERC20.transferFrom(msg.sender, tokenERC721.ownerOf(tokenId), seller);
        tokenERC20.transferFrom(msg.sender, 0x105Bf69efe1Da6697e62bEA4193cFC3C8c35418b, dev);
        
        tokenERC721.transferFrom(tokenERC721.ownerOf(tokenId), msg.sender, tokenId);
        delete NFTSales[tokenId];
        remove(indexOf(tokenId));
    }
    
    function removeListSaller(uint256 tokenId) public {
        require(msg.sender==tokenERC721.ownerOf(tokenId), "you don't own the nft");
        delete NFTSales[tokenId];
        remove(indexOf(tokenId));
    }
    
    function getByTokenId(uint256 tokenId) public view returns(uint256, address, uint256) {
        return (NFTSales[tokenId].tokenId, NFTSales[tokenId].owner, NFTSales[tokenId].price);
    }
    
    function getAllNFTs() public view returns(uint[] memory) {
        return tokensId;
    }
    
    function remove(uint index) private {
        if (index >= tokensId.length) return;

        for (uint i = index; i<tokensId.length-1; i++){
            tokensId[i] = tokensId[i+1];
        }
        tokensId.pop();
    }
    
    function indexOf(uint256 tokenId) private view returns(uint){
        for(uint i=0; i<tokensId.length; i++){
            if(uint(tokensId[i])==uint(tokenId)){
                return i;
            }
        }
        return 1000000000;
    }
}