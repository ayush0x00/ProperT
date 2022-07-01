pragma solidity ^0.8.0;

import "../MintingContracts/MintLand.sol";
import "../MintingContracts/MintLord.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Rental{
    using SafeMath for uint256;
    address owner;
    LandNFT landNFTContract;
    LordNFT lordNFTContract;
    mapping(address => mapping(uint256 => uint256)) landMarkedForRentTime;
    mapping(address => uint256[3]) landsPerLord;
    uint256 amountToBeDistributed;
    constructor (address _landNFT, address _lordNFT){
        owner=msg.sender;
        landNFTContract = LandNFT(payable(_landNFT));
        lordNFTContract = LordNFT(payable(_lordNFT));    
    }

    receive() external payable {}
    
    function transferAmount(address payable _to, uint256 amnt) public payable{
        (bool sent, bytes memory data) = _to.call{value: amnt}("");
        require (sent, "Failed to send amount");
    }


    function signUpForRent(uint256 landTokenId, uint256 lordTokenId) public {
        require(msg.sender == landNFTContract.ownerOf(landTokenId) && msg.sender == lordNFTContract.ownerOf(lordTokenId));
        uint8 lordType = lordNFTContract.tokenIdToLordType(lordTokenId);
        uint256 landsAllowedForLord = lordNFTContract.maxLordRentLimit(lordType);
        require(landsAllowedForLord > landsPerLord[msg.sender][lordType-1],"Lord limit reached");
        landMarkedForRentTime[msg.sender][landTokenId] == block.timestamp;
        landsPerLord[msg.sender][lordType-1] += 1;
    }

    function getEachDayRent(uint256 landTokenId) public view returns(uint256){
        uint8 typeOfLand = landNFTContract.tokenIdToLandType(landTokenId);
        uint256 weight = getWeightOfLand(typeOfLand);
        return weight.mul(amountToBeDistributed).div(landNFTContract.numberOfMints(typeOfLand-1));
    }

    function getTotalRent(address user, uint256 landTokenId) public view returns(uint256){
        uint256 landBuyTime = landNFTContract.landBoughtAt(landTokenId);
        uint256 _markTime = landMarkedForRentTime[user][landTokenId];
        require( landBuyTime <= _markTime);
        uint256 totalRentDays = block.timestamp.sub(_markTime).div(86400);
        return totalRentDays.mul(getEachDayRent(landTokenId));
    }

    function withdrawRent(uint256 landTokenId, uint256 lordTokenId) public payable{
        require(msg.sender == landNFTContract.ownerOf(landTokenId) && msg.sender == lordNFTContract.ownerOf(lordTokenId));
        uint256 rent = getTotalRent(msg.sender, landTokenId);
        transferAmount(payable(msg.sender), rent);
        uint8 lordType = lordNFTContract.tokenIdToLordType(lordTokenId);
        landsPerLord[msg.sender][lordType-1] -= 1;
    }

    function getWeightOfLand(uint256 typeOfLand) public view returns(uint256){
        uint256 sumWeightMintProd = 0;
        for(uint8 i=0; i<3; i++){
            sumWeightMintProd += landNFTContract.costOfLand(i).mul(landNFTContract.numberOfMints(i));
        }

        return landNFTContract.costOfLand(typeOfLand-1).div(sumWeightMintProd);
    }

    function rentToDistribute() public payable{
        require(msg.sender == owner);
        amountToBeDistributed = msg.value;
    }

}