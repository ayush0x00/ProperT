pragma solidity ^0.8.0;

import "../MintingContracts/MintLand.sol";
import "../MintingContracts/MintLord.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Rental{
    using SafeMath for uint256;
    address owner;
    LandNFT landNFTContract;
    LordNFT lordNFTContract;
    mapping(address => mapping(uint256 => uint256)) landLastReedemedTime;
    mapping(address => mapping(uint256 => uint8)) landsRedeemedByLord;
    mapping(address => uint256[3]) landsPerLord;  // [0,0,0]
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
/*
curr lord = [1,1,1]
A2 B2 C1 => 
1   2   3
[1,2,3] => 
mapping(0x, [0,2,0]) 
*/

    function getEachDayRent(uint256 landTokenId) public view returns(uint256){
        uint8 typeOfLand = landNFTContract.tokenIdToLandType(landTokenId);
        uint256 weight = getWeightOfLand(typeOfLand);
        return weight.mul(amountToBeDistributed).div(landNFTContract.numberOfMints(typeOfLand-1));
    }

    function _max(uint256 a, uint256 b) private pure returns(uint256){
        return (a > b ? a : b);
    }

    function getTotalRent(address user, uint256 landTokenId, uint256 lordTokenId) public view returns(uint256){
        uint256 landBuyTime = landNFTContract.landBoughtAt(landTokenId);
        uint256 lordBuyTime = lordNFTContract.lordBoughtAt(lordTokenId);
        uint256 _startTimeForRent =  _max(landBuyTime,lordBuyTime).sub(landLastReedemedTime[user][landTokenId]);
        uint256 totalRentDays = block.timestamp.sub(_startTimeForRent).div(1 days);
        return totalRentDays.mul(getEachDayRent(landTokenId));
    }
    // lord 2 land
// l0 = [2] [l1,l2] l0, l1
    function withdrawRent(uint256 landTokenId, uint256 lordTokenId) public payable{
        require(msg.sender == landNFTContract.ownerOf(landTokenId) && msg.sender == lordNFTContract.ownerOf(lordTokenId));
        uint8 lordType = lordNFTContract.tokenIdToLordType(lordTokenId);

        if(block.timestamp.sub(landLastReedemedTime[msg.sender][landTokenId]) < 30 days){
            require(landsRedeemedByLord[msg.sender][lordTokenId] < lordNFTContract.maxLordRentLimit(lordType));
        }
        else{
            landsRedeemedByLord[msg.sender][lordTokenId] = 0;
        }
        landsRedeemedByLord[msg.sender][lordTokenId] += 1;
        uint256 rent = getTotalRent(msg.sender, landTokenId, lordTokenId);
        transferAmount(payable(msg.sender), rent);
        landsPerLord[msg.sender][lordType-1] -= 1;
        landLastReedemedTime[msg.sender][landTokenId] = block.timestamp;
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