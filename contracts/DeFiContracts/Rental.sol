pragma solidity ^0.8.0;

import "../MintingContracts/MintNft.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Rental{
    using SafeMath for uint256;
    address owner;
    NFT LandLordNFTContract;
    //LordNFT LordNFTContract;
    constructor (address _landLordNFT){
        owner=msg.sender;
        LandLordNFTContract= NFT(_landLordNFT);
        
    }

    receive() external payable {}

    function transferAmount(address payable _to, uint256 amnt) public payable{
        (bool sent, bytes memory data) = _to.call{value: amnt}("");
        require (sent, "Failed to send amount");
    }

    function sumOfWeightNumberProd() private view returns(uint256){
        uint256 result=0;
        for(uint8 i= 1; i<=3; i++){
            result += LandLordNFTContract.getNumberOfMints(i).mul(LandLordNFTContract.getWeight(i));
        }
        return result;
    }

    function getMyRent(address user) private view returns(uint256) {
        (bool available,uint8 typeofLand,,,uint256 startTime,uint256 totalRentalTime) = LandLordNFTContract.userInfo(user);

        uint256 numberOfMints = LandLordNFTContract.getNumberOfMints(typeofLand);
        uint256 weightOfLand = LandLordNFTContract.getWeight(typeofLand);
        
        uint256 perDayRent = (numberOfMints.mul(weightOfLand)).div(sumOfWeightNumberProd());
        if(!available) return perDayRent.mul(totalRentalTime.div(86400));
        return perDayRent.mul((totalRentalTime.add(block.timestamp.sub(startTime))).div(86400));
    }

    function withdrawRent() public payable{
        uint256 totalRent = getMyRent(msg.sender);
        require(totalRent > 0, "Nothing to withdraw");
        transferAmount(payable(msg.sender), totalRent);
        LandLordNFTContract.setUserForRent(msg.sender);
    }

}