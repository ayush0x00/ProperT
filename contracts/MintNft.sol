// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFT is ERC721,ERC721URIStorage{
    uint256 public totalNFT=0;
    uint256 public TOTAL_LAND=2000; //hard coded value

    event tokenCreated(uint256,string);
    mapping(address=> uint256[]) public boostsOfUser;
    mapping(address=>uint256) public landOfUser;
    address[] public allUsers;
    constructor() ERC721("ProperT","PRT"){}

    function mint(string memory _tokenURI) public {
        totalNFT+=1;
        _mint(msg.sender, totalNFT);
        _setTokenURI(totalNFT,_tokenURI);
        allUsers.push(msg.sender);
        emit tokenCreated(totalNFT,tokenURI(totalNFT));
    }

    function _burn(uint256 tokenId) internal override(ERC721URIStorage, ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage,ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function getTotalSupply() public view returns(uint256){
        return totalNFT;
    }

    function updateTokenURI(uint256 tokenId, string memory _newURI) public{
        require(msg.sender==ownerOf(tokenId),"You are not the owner of the token");
        _setTokenURI(tokenId, _newURI);
    }
}