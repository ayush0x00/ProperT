pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./StakingContract.sol";
import "./VerionToken.sol";

contract main{
    address admin;
    ERC20 verion;

    constructor(ERC20 token) {
        verion=token;
        admin=msg.sender;
    }

    // staking[] public stakingPools;
    staking private s;

    modifier onlyAdmin(){
        require(msg.sender==admin,"Not an admin");
        _;
    }

    function createStakingPool(uint256 startBlock, uint256 endBlock,uint256 rewardPerBlock) public onlyAdmin{
        s=new staking(verion,rewardPerBlock,startBlock,endBlock,admin);
        //stakingPools.push(s);
    }

    function stake() public{
        s.depositToken();
    }

    function withdrawToken(uint256 amount) public{
        s.withdraw(amount);
    }
}