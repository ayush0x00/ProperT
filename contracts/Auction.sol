// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Base.sol";

 contract Auction is Base  {

    uint256 auctionCount=1;
    event AuctionCreated(address);
    mapping(uint256=>address) auctions;
    event Bidding(address[]);

    address owner;
    uint256 _startBlock;
    uint256 _endBlock;
    uint256 [] internal listedNFT;
    mapping (uint256=>address[]) bidders;
    mapping(uint256=>mapping(address=>uint256)) amountBidded;
    mapping(uint256=>uint256) internal bid;
    mapping(uint256=>address) highestBidAddress;
    bool auctionCancelled=false;

    
    constructor(){
        owner=msg.sender;
    }

    modifier auctionGoing(uint256 start,uint256 end){
        require(!auctionCancelled && block.number>_startBlock && block.number<_endBlock);
        _;
    }

    modifier auctionEnded(uint256 start, uint256 end){
        require(!auctionCancelled && block.number>_endBlock);
        _;
    }

    function createAuction(uint256 start, uint256 end) public{
        require(block.number<start && start<=end);
        require(msg.sender==owner);
        _startBlock=start;
        _endBlock=end;
        auctions[auctionCount]=address(this);
        auctionCount+=1;
    }


    // function getBidders(uint256 id) public view returns(address[] memory){
    //     return bidders[id];
    // }

    function listForAuction(uint256 id)  public payable{
        require(block.number<_startBlock,"Auction is already started");
        require(getBalance(msg.sender,id)>0,"Only owner can list for auction"); 
        listedNFT.push(id);
        bid[id]=msg.value;
    }


    function cancelAuction() public{
        require(msg.sender==owner && block.number<_startBlock);
        auctionCancelled=true;
    }

    function Bid(uint256 id) public payable {
        address nftOwner=Base.nftHolders[id];
        require(nftOwner!=msg.sender,"Owner can not bid for item");
        require(msg.value>bid[id]);
        bid[id]=msg.value;
        highestBidAddress[id]=msg.sender;
        address[] storage exisitingBidders=bidders[id];
        bool exisits=false;
        for(uint i=0;i<exisitingBidders.length;i++){
            if(exisitingBidders[i]==msg.sender){
                exisits=true;
                break;
            }
        }
        if(!exisits) bidders[id].push(msg.sender);
        amountBidded[id][msg.sender]=msg.value;
    }
    
}