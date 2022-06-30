// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract NFT is ERC721,ERC721URIStorage{
    using SafeMath for uint256;

    uint256 totalSupply=0;
    uint256 totalLand=0;
    uint256 totalLord=0;
    uint256[3] public weightsOfLand = [0,0,0];  //idx 0 => weight of land of type 1 and so on
    uint256[3] public numberofMints = [0,0,0];
    uint256 public sumOfLandWeights;
    address owner;
    event Breach(address user);
    event lordMinted(uint256 tokenId);
    event landMinted(uint256 tokenId);
    string private salt="1234";
    mapping (uint256 => bool) isLand; // true if land, else false if lord
    mapping (address=> User) public userInfo;
    
    constructor() ERC721("ProperT","PRT"){
        owner = msg.sender;
    }

    struct User{
        bool availableForRent;
        uint8 retalLandType;
        uint16 numberOfLandsOwned;
        uint16 numberOfLordsOwned;
        uint256 startTimeWithLordLand;
        uint256 totalPreviousRentalTime;
    }

    function deposit(uint256 amount) public payable{}

    //typeOfLand => 1 for normal and so on...

    function mint(bytes32 hashVal, uint256 tokenId, string memory _tokenURI, bool lord, uint8 typeOfLand) public payable {
        bytes memory  preHash = bytes(abi.encodePacked(Strings.toString(msg.value),salt));
        bytes32 expectedHash = sha256(preHash);
        if(expectedHash != hashVal){
            emit Breach(msg.sender);
            revert("Invalid hash");
        }
        deposit(msg.value);
        _mint(msg.sender, tokenId);
        totalSupply+=1;
        _setTokenURI(tokenId,_tokenURI);
        User storage _user = userInfo[msg.sender];
        if(lord){
            emit lordMinted(tokenId);
            _user.numberOfLordsOwned +=1 ;
            totalLord+=1;
        } 
        else{
            emit landMinted(tokenId);
            _user.numberOfLandsOwned +=1;
            totalLand+=1;
            numberofMints[typeOfLand-1] += 1;
        } 
    }

    function TransferNFT(address from, address to, uint256 tokenId) public{
        _transfer(from, to, tokenId);
        User storage sender= userInfo[from];
        User storage receiver = userInfo[to];

        if(isLand[tokenId]){
            sender.numberOfLandsOwned -= 1;
            receiver.numberOfLandsOwned += 1;
        }
        else{
            sender.numberOfLordsOwned -= 1;
            receiver.numberOfLordsOwned -= 1;
        }

        if(sender.availableForRent){
            if(sender.numberOfLandsOwned == 0 || sender.numberOfLordsOwned == 0){
                sender.availableForRent = false;
                sender.startTimeWithLordLand = 0;
                sender.totalPreviousRentalTime += block.timestamp.sub(sender.startTimeWithLordLand);
            }
        }
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal override {
        TransferNFT(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        TransferNFT(from, to, tokenId);
    }



    function _burn(uint256 tokenId) internal override(ERC721URIStorage, ERC721) {
        super._burn(tokenId);
        totalSupply-=1;

        if(isLand[tokenId]) totalLand-=1;
        else totalLord-=1;
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
        return totalSupply;
    }

    function updateTokenURI(uint256 tokenId, string memory _newURI) public{
        require(msg.sender==ownerOf(tokenId),"not allowed");
        _setTokenURI(tokenId, _newURI);
    }

    function setWeightOfLand(uint8 typeofLand, uint256 _weight) public {
        require(msg.sender == owner);
        sumOfLandWeights -= weightsOfLand[typeofLand-1];
        sumOfLandWeights += _weight;
        weightsOfLand[typeofLand - 1] = _weight;
    }

    function getWeight(uint8 typeofLand) public view returns(uint256){
        return weightsOfLand[typeofLand-1].div(sumOfLandWeights);
    }

    function getNumberOfMints(uint8 typeofLand) public view returns(uint256){
        return numberofMints[typeofLand-1];
    }

    function setSalt(string memory newSalt) private {
        require(msg.sender==owner);
        salt=newSalt;
    }

    function setUserForRent(address user) public{
        User storage _user = userInfo[user];
        require(_user.numberOfLandsOwned > 0 && _user.numberOfLordsOwned > 0,"Not available");
        if(_user.availableForRent){
            _user.totalPreviousRentalTime += block.timestamp.sub(_user.startTimeWithLordLand);
        }
        _user.availableForRent = true;
        _user.startTimeWithLordLand = block.timestamp;
    }

}