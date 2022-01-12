// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFT is ERC721,ERC721URIStorage{
    uint256 public totalNFT=0;
    uint256 public TOTAL_LAND=2000; //hard coded value
    address adminNft;
    mapping(address=> uint256[]) public boostsOfUser;
    mapping(address=>uint256) public landOfUser;
    address[] public allUsers;
    string private salt;

    constructor() ERC721("ProperT","PRT"){
        adminNft = msg.sender;
    }

    function deposit(uint256 amount) public payable{}

    function mint(string memory hashVal, string memory _tokenURI) public payable {
        uint256 cost= msg.value;
        bytes memory  preHash = bytes(abi.encodePacked(cost,salt));
        bytes32 expectedHash = sha256(preHash);
        bytes32 receivedHash = stringToBytes32(hashVal);
        require(expectedHash == receivedHash,"Breach alert");
        totalNFT+=1;
        deposit(msg.value);
        _mint(msg.sender, totalNFT);
        _setTokenURI(totalNFT,_tokenURI);

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
        require(msg.sender==ownerOf(tokenId),"not allowed");
        _setTokenURI(tokenId, _newURI);
    }

    function setSalt(string memory newSalt) private {
        require(msg.sender==adminNft);
        salt=newSalt;
    }


    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}