// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialMedia{
    address owner;
    constructor(){
        owner=msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }

    mapping(string=>address) internal campaigns;
    mapping(string=>mapping(string=>uint256)) internal degradingFactor;
    mapping(string=>mapping(string=>uint256)) internal individualWeightMatrix; 
    //rows= twitter,instagram,facebook
    //columns= likes, comment, others
    uint256 private instaW;
    uint256 private twitterW;
    uint256 private youtubeW;

    function setWeights(string memory platform, string memory field,uint256 w) private onlyOwner{
        individualWeightMatrix[platform][field]=w;
    }

// user total engagement on all platforms/total engagement of all users * number of tokens in contract

    function setInstaDegrading(string memory userId, string memory platform,uint256 d) private onlyOwner{
        degradingFactor[userId][platform]=d;
    }
    function setTwitterDegrading(string memory userId, string memory platform,uint256 d) private onlyOwner{
        degradingFactor[userId][platform]=d;
    }
    function setYoutubeDegrading(string memory userId, string memory platform,uint256 d) private onlyOwner{
        degradingFactor[userId][platform]=d;
    }

}