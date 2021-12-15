// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./MintNft.sol";

contract LandRent is NFT{
    using SafeMath for uint256;
    mapping(address=>uint256) private rentAvailable;
    bool collectRentMode=false;

    address admin;
    constructor(){
        admin=msg.sender;
    }
    uint256 originalLand=NFT.TOTAL_LAND;
    uint256 virtualLand=0;

    modifier onlyAdmin{
        require(msg.sender==admin,"Only owner can permit");
        _;
    }

    function getMaxBoost(address user) public view returns(uint256){
        uint256 maxBoost=0;
        uint256[] memory boosts=NFT.boostsOfUser[user];
        for(uint256 i=0;i<boosts.length;i++){
            if(boosts[i]>maxBoost) maxBoost=boosts[i];
        }
        return maxBoost;
    }

    function startCollection() public onlyAdmin{
        collectRentMode=true;
    }

    function stopCollection() public onlyAdmin{
        collectRentMode=false;
    }

    function safeTransferEth(address to, uint256 value) private {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        // (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function updateVirtualLand() public {
        for(uint256 i=0;i<NFT.allUsers.length;i++){
            address user=NFT.allUsers[i];
            uint256 boost=getMaxBoost(user);
            uint256 land=NFT.landOfUser[user];
            virtualLand+=land.mul(boost.div(100)+1);
        }
    }

    function distributeRent() public onlyAdmin{
        uint256 balanceAvl=address(this).balance;
        for(uint256 i=0;i<NFT.allUsers.length;i++){
            address user=NFT.allUsers[i];
            uint256 rent=NFT.landOfUser[user].div(virtualLand).mul(balanceAvl);
            rentAvailable[user]+=rent;
        }
    }

    function collectRent() public payable{
        require(collectRentMode==true,"Can't collect rent now");
        address user=msg.sender;
        safeTransferEth(user, rentAvailable[user]);
        rentAvailable[user]=0;
    }
}