// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Base is ERC1155{
    uint256 currentId=1;
    mapping(uint256 =>address) internal nftHolders;
    event minted(address,uint256,uint256);

    constructor() ERC1155("https://ipfs.io/ipfs/QmQUq6VmLzSKvYFJTWe7zgzUAkWVpsGTd2LyekmwdvAzvz/{id}.json") {
    }

    function mintNFT(uint256 amt) public{
        _mint(msg.sender, currentId, amt,"");
        nftHolders[currentId]=msg.sender;
        emit minted(msg.sender,currentId,amt);
        currentId+=1;  
    }

    function getBalance(address acc, uint256 id) internal view returns(uint256){
        return balanceOf(acc,id);
    }
    

    function transferNFT(address from, address to, uint256 id, uint256 amnt) internal{
        _safeTransferFrom(from, to, id, amnt,"");
    }

    function totalSupply() internal view returns(uint256){
        return currentId;
    }
}
