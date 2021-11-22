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

    mapping(string=>mapping(string=>uint256)) private userWeights;
    mapping(string=>mapping(string=>uint256)) private degradingFactor;
    mapping(string=>mapping(string=>uint256)) private individualWeightMatrix; 
    //rows= twitter,instagram,facebook
    //columns= likes, comment, others
    uint256 private instaW;
    uint256 private twitterW;
    uint256 private youtubeW;

    function setWeights(string memory platform, string memory field,uint256 w) private onlyOwner{
        individualWeightMatrix[platform][field]=w;
    }



    function setInstaDegarading(string memory userId, string memory platform,uint256 d) private onlyOwner{
        degradingFactor[userId][platform]=d;
    }
    function setTwitterDegarading(string memory userId, string memory platform,uint256 d) private onlyOwner{
        degradingFactor[userId][platform]=d;
    }
    function setYoutubeDegarading(string memory userId, string memory platform,uint256 d) private onlyOwner{
        degradingFactor[userId][platform]=d;
    }

    function setTwitterWeight(uint256 w) private onlyOwner{
        twitterW=w;
    }

    function setYoutubeW(uint256 w) private onlyOwner{
        youtubeW=w;
    }

    function updateUserWeights(string memory userId, string memory platform, string memory field, uint256 n) public{
        // uint256 iw=weights[0]+instaW;
        // uint256 tw=weights[1]+twitterW;
        // uint256 yw=weights[2]+youtubeW;
        // uint256[] memory previousW=userWeights[userId];
        // iw+=previousW[0]-degradingFactor[userId][0];
        // tw+=previousW[1]-degradingFactor[userId][1];
        // yw+=previousW[2]-degradingFactor[userId][2];
        // userWeights[userId]=[iw,tw,yw];
        uint256 reward=n*(individualWeightMatrix[platform][field]);
        userWeights[userId][platform]=reward-degradingFactor[userId][platform];
    }

}