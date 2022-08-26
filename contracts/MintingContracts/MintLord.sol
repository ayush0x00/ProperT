// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LordNFT is ERC721, ERC721URIStorage{
    address owner;
    uint256[3] costOfLord = [0,0,0]; // stores cost of lord. costOfLord[0] stores cost of lord of type 1 and so on.
    uint8[3] public maxLordRentLimit = [0,0,0]; // maxLordLimit[i] gives maximum amount of land (i+1)th lord can rent
    event Breach(address user);
    string private salt="1234";
    mapping (uint256 => uint8) public tokenIdToLordType; // stores token id to type of lord
    mapping (address => User) userInfo;
    mapping (uint256 => uint256) public lordBoughtAt; // stores time when the particular lord was bought

    struct User{
        uint256[3] lordsOwned; // lordsOwned[i] gives number of lord of type (i+1) which the user owns.
    }

    constructor() ERC721("LOL Lord NFTS","LORDS"){
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    receive() external payable {}

// Similar kind of miniting as compared with MintLand
    function mint(bytes32 hashVal, uint256 tokenId, string memory _tokenURI, uint8 typeOfLord) public payable {
        bytes memory  preHash = bytes(abi.encodePacked(Strings.toString(msg.value),salt));
        bytes32 expectedHash = sha256(preHash);
        if(expectedHash != hashVal){
            emit Breach(msg.sender);
            revert("Invalid hash");
        }
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId,_tokenURI);
        tokenIdToLordType[tokenId] = typeOfLord;
        User storage _user = userInfo [msg.sender];
        _user.lordsOwned[typeOfLord-1] += 1; 
    }

    function _transfer(address from, address to, uint256 tokenId) internal override{
        User storage _sender = userInfo[from];
        User storage _receiver = userInfo[to];
        uint8 typeOfLord = tokenIdToLordType[tokenId];
        _sender.lordsOwned[typeOfLord-1] -= 1;
        _receiver.lordsOwned[typeOfLord-1] += 1;
        lordBoughtAt[tokenId] = block.timestamp;
        super._transfer(from,to,tokenId);
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

    function setCostOfLord(uint8 typeOfLord, uint256 _price) public onlyOwner{
        costOfLord[typeOfLord-1] = _price;
    }

    function setMaxLordRentLimit(uint8 typeOfLord, uint8 _limit) public onlyOwner{
        maxLordRentLimit[typeOfLord-1] = _limit;
    }

    function getLordsOwned(address user, uint8 typeOfLord) external view returns(uint256){
        return userInfo[user].lordsOwned[typeOfLord-1];
    }
    
    function updateSalt(string _salt) public onlyOwner{
        salt = _salt;
    }
    
}