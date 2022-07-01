// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LandNFT is ERC721, ERC721URIStorage{
    address owner;
    uint256[3] public costOfLand = [0,0,0];
    uint256[3] public numberOfMints = [0,0,0];
    event Breach(address user);
    string private salt="1234";
    mapping (uint256 => uint8) public tokenIdToLandType;
    mapping (uint256 => uint256) public landBoughtAt;
    mapping (address => User) userInfo;

    struct User{
        bool availableForRent;
        uint256[3] landsOwned;
    }

    constructor() ERC721("LOL Land NFTS","LANDS"){
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function mintLand(bytes32 hashVal, uint256 tokenId, string memory _tokenURI, uint8 typeOfLand) public payable{
        require(costOfLand[typeOfLand-1] == msg.value, "Incorrect typeOfLand");

        bytes memory  preHash = bytes(abi.encodePacked(Strings.toString(msg.value),salt));
        bytes32 expectedHash = sha256(preHash);
        if(expectedHash != hashVal){
            emit Breach(msg.sender);
            revert("Invalid hash");
        }
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId,_tokenURI);
        tokenIdToLandType[tokenId] = typeOfLand;
        User storage _user = userInfo [msg.sender];
        _user.landsOwned[typeOfLand-1] += 1;
        landBoughtAt[tokenId] = block.timestamp;
        numberOfMints[typeOfLand-1] += 1; 
    }

    function _transfer(address from, address to, uint256 tokenId) internal override{
        User storage _sender = userInfo[from];
        User storage _receiver = userInfo[to];
        uint8 typeOfLand = tokenIdToLandType[tokenId];
        _sender.landsOwned[typeOfLand-1] -= 1;
        _receiver.landsOwned[typeOfLand-1] += 1;
        landBoughtAt[tokenId] = block.timestamp;
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

    function setCostOfLand(uint8 typeOfLand, uint256 _price) public onlyOwner{
        costOfLand[typeOfLand-1] = _price;
    }

    function getLandsOwned(address user, uint8 typeOfLand) external view returns(uint256){
        return userInfo[user].landsOwned[typeOfLand-1];
    }
}