// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SocialMedia.sol";

contract Campaign is SocialMedia{
    address CampaignOwner;
    uint256 private totalEngagement;
    uint256 private coinsAvailable;

    constructor(string memory campaignTag,uint initCoins){
        SocialMedia.campaigns[campaignTag]=address(this);
        coinsAvailable=initCoins;
    }

    mapping(string=>mapping(string=>uint256)) public userReward;


    function updateUserReward(string memory userId, string memory platform, uint256[] memory data) public{
        uint256 likeReward=data[0]*SocialMedia.individualWeightMatrix[platform]["likes"];
        uint256 commentReward=data[1]*SocialMedia.individualWeightMatrix[platform]["comments"];
        uint256 otherReward=data[2]*SocialMedia.individualWeightMatrix[platform]["others"];

        uint256 totalUserReward=likeReward+commentReward+otherReward;
        userReward[userId][platform]+=totalUserReward;

        totalEngagement+=totalUserReward;
    }

    function getUserShare(string memory userId) public view returns (uint256){
        uint256 totalUserEngagement= userReward[userId]["twitter"]+userReward[userId]["facebook"]+userReward[userId]["instagram"];
        return (totalUserEngagement/totalEngagement)*coinsAvailable;
    }
}