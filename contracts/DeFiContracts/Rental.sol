pragma solidity ^0.8.0;

import "../MintingContracts/MintLand.sol";
import "../MintingContracts/MintLord.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Rental{
    using SafeMath for uint256;
    address owner;
    LandNFT landNFTContract;
    LordNFT lordNFTContract;
    mapping(address => mapping(uint256 => uint256)) landMarkedForRent;
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


    function signUpForRent(uint256 landTokenId, uint256 lordTokenId) public view{
        require(msg.sender == landNFTContract.ownerOf(landTokenId) && msg.sender == lordNFTContract.ownerOf(lordTokenId));
        landMarkedForRent[msg.sender][landTokenId] == block.timestamp;
    }

    function getEachDayRent(uint256 landTokenId) public view returns(uint256){

    }

    function getTotalRent(address user, uint256 landTokenId) public view returns(uint256){
        uint256 landBuyTime = landNFTContract.landBoughtAt(landTokenId);
        uint256 landMarkedForRentTime = landMarkedForRent[user][landTokenId];
        require( landBuyTime <= landMarkedForRentTime);
        uint256 totalRentDays = block.timestamp.sub(landMarkedForRentTime).div(86400);
        return totalRentDays.mul(getEachDayRent(landTokenId));
    }

    function withdrawRent(uint256 landTokenId, uint256 lordTokenId) public payable{
         
    }

    function getWeightOfLand(uint256 typeOfLand) public view returns(uint256){
        uint256 sumWeightMintProd = 0;
        for(uint8 i=0; i<3; i++){
            sumWeightMintProd += landNFTContract.costOfLand(i).mul(landNFTContract.numberOfMints(i));
        }

        return landNFTContract.costOfLand(typeOfLand-1).div(sumWeightMintProd);
    }

}