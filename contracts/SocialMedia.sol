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

    mapping(address=>uint256[]) private userWeights;
    mapping(address=>uint256[]) private degradingFactor;
    uint256 private instaW;
    uint256 private twitterW;
    uint256 private youtubeW;

    function setInstaWeight(uint256 w) private onlyOwner{
        instaW=w;
    }

    function setInstaDegarading(address user, uint256 d) private onlyOwner{
        degradingFactor[user][0]=d;
    }
    function setTwitterDegarading(address user, uint256 d) private onlyOwner{
        degradingFactor[user][1]=d;
    }
    function setYoutubeDegarading(address user, uint256 d) private onlyOwner{
        degradingFactor[user][2]=d;
    }

    function setTwitterWeight(uint256 w) private onlyOwner{
        twitterW=w;
    }

    function setYoutubeW(uint256 w) private onlyOwner{
        youtubeW=w;
    }

    function updateUserWeights(address user, uint256[] memory weights) public{
        uint256 iw=weights[0]*instaW;
        uint256 tw=weights[1]*twitterW;
        uint256 yw=weights[2]*youtubeW;
        uint256[] memory previousW=userWeights[user];
        iw+=previousW[0]-degradingFactor[user][0];
        tw+=previousW[1]-degradingFactor[user][0];
        yw+=previousW[2]-degradingFactor[user][0];
        userWeights[user]=[iw,tw,yw];
    }

}