// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Auction.sol";
import "./Base.sol";

contract Main is Base,Auction{
    address payable god;
    Base bc;
    constructor(){
        god=payable(msg.sender);
        bc=new Base();
    }

    function getOwner() public view returns(address){
        return god;
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function mint(uint256 amnt) public{
        Base.mintNFT(amnt);
    }

    function send(address payable _to,uint256 value) public payable {
        (bool sent,) = _to.call{value: value}("");
        require(sent, "Failed to send Ether");
    }

    // function getBidder() public view returns( mapping (uint256=>address[])){
    //     return Auction.bidders;
    // }

    function distributeFunds() private {
        for(uint i=0;i<Auction.listedNFT.length;i++){
            uint256 id=Auction.listedNFT[i];
            
            //Distributing fund to owner of nft
            uint256 amntHighest=Auction.bid[id];
            address nftowner=Base.nftHolders[id];
            send(payable(nftowner), amntHighest);

            //Distributing funds to all the bidders who lost the auction
            address[] memory allbidders=Auction.bidders[id];
            for(uint j=0;j<allbidders.length;j++){
                address bidder=allbidders[j];
                if(bidder==Auction.highestBidAddress[id]) continue;
                uint256 amnt=Auction.amountBidded[id][bidder];
                send(payable(bidder),amnt);
            }
        }
    }

    function getBidders(uint256 id) public view  returns(address[] memory){
        return Auction.bidders[id];
    }

    function bal(address acc, uint256 id) public view returns(uint256){
        return Base.getBalance(acc, id);
    }

    function getAuctionResult() public{
        distributeFunds();
        for(uint i=0;i<Auction.listedNFT.length;i++){
            uint256 id=Auction.listedNFT[i];
            address nftOwner=Base.nftHolders[id];
            Base.transferNFT(nftOwner, Auction.highestBidAddress[id], id, 1);
            Base.nftHolders[id]=Auction.highestBidAddress[id];
        }
    }
}