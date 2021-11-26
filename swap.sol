/**
 *Submitted for verification at BscScan.com on 2021-06-05
*/

// The MIT License (MIT)
// Copyright (c) 2016-2019 zOS Global Limited

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
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