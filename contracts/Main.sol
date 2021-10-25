// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Main is ERC1155 {
    uint256 currentId=0;
    address owner;
    uint256 _startBlock;
    uint256 _endBlock;
    mapping(uint256 =>address) private nftHolders;
    bool [] private isListed;
    mapping(uint256=>uint256) private bid;
    mapping(uint256=>address) highestBidAddress;
    bool auctionOpen=false;
    bool auctionCancelled=false;

    constructor() ERC1155("https://ipfs.io/ipfs/QmQUq6VmLzSKvYFJTWe7zgzUAkWVpsGTd2LyekmwdvAzvz/{id}.json") {
        owner=msg.sender;
    }

    modifier validListCond(uint256 id){
        require(nftHolders[id]==msg.sender,"Only owner can list for auction");
        require(auctionOpen,"Auction is not open");
        _;
    }

    function mintNFT(uint amt) public{
        _mint(msg.sender, currentId, amt,"");
        nftHolders[currentId]=msg.sender;
        currentId+=1;
    }
    function getOwner(uint256 id) public view returns(address){
        return nftHolders[id];
    }

    function createAuction(uint256 startBlock, uint256 endBlock) public{
        require(msg.sender==owner && !auctionOpen);
        require(block.number<startBlock && startBlock<=endBlock);
        _startBlock=startBlock;
        _endBlock=endBlock;
        auctionOpen=true;
        auctionCancelled=false;
    }

    function isAuctionOpen() public view returns(bool){
        return auctionOpen;
    }

    function listForAuction(uint256 id,uint initBid)  public{ 
        isListed.push(true);
        bid[id]=initBid;
    }

    function cancelAuction() public{
        require(msg.sender==owner && block.number<_startBlock);
        auctionOpen=false;
        auctionCancelled=true;
    }

    function Bid(uint256 id) public payable{
        require(nftHolders[id]!=msg.sender,"Owner can not bid for item");
        require(msg.value>bid[id]);
        bid[id]=msg.value;
        highestBidAddress[id]=msg.sender;
    }

    function getAuctionResult() public payable{
        require(!auctionCancelled && block.number>=_endBlock);
        for(uint i=0;i<isListed.length;i++){
            if(isListed[i]){
                _safeTransferFrom(nftHolders[i], highestBidAddress[i], i, 1, "");
                nftHolders[i]=highestBidAddress[i];
                bid[i]=0;
            }
        }
    }
}