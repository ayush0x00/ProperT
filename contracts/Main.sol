// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Main is ERC1155 {
    uint256 currentId=1;
    address owner;
    mapping(uint256 =>address) private nftHolders;
    mapping(uint256=>bool) private isListed;
    mapping(uint256=>uint[2]) private timing;

    constructor() ERC1155("https://ipfs.io/ipfs/QmQUq6VmLzSKvYFJTWe7zgzUAkWVpsGTd2LyekmwdvAzvz/{id}.json") {
        owner=msg.sender;
    }

    function mintNFT(uint amt) public{
        _mint(msg.sender, currentId, amt,"");
        nftHolders[currentId]=msg.sender;
        currentId+=1;
    }
    function getOwner(uint256 id) public view returns(address){
        return nftHolders[id];
    }

    function isAuctionOpen(uint256 id, uint256 currentTime) public view returns(bool){
        return timing[id][1]>currentTime;
    }

    function listForAuction(uint256 id,uint256 start,uint256 end) public{
        require(nftHolders[id]==msg.sender,"Only owner can list for auction");
        isListed[id]=true;
        timing[id]=[start,end];
    }
}