pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./StakingContract.sol";

contract main{
    using SafeMath for uint256;
    address admin;
    ERC20 viron;
    uint256 totalSupplyAvailable;
    uint256 stakingPercentage=25;
    uint256 totalNFTS=0;

    constructor(ERC20 token) {
        viron=token;
        admin=msg.sender;
        totalSupplyAvailable=viron.balanceOf(address(this));
    }


    // staking[] public stakingPools;
    staking private s;

    modifier onlyAdmin(){
        require(msg.sender==admin,"Not an admin");
        _;
    }

    function updateSupply() public onlyAdmin{
        totalSupplyAvailable=viron.balanceOf(address(this));
    }

    function createStakingPool(uint256 startBlock, uint256 endBlock) public onlyAdmin{
        s=new staking(viron,(totalSupplyAvailable.mul(stakingPercentage).div(100)),startBlock,endBlock,admin);
        //stakingPools.push(s);
    }

    function stake() public{
        s.depositToken();
    }

    function withdrawToken(uint256 amount) public{
        s.withdraw(amount);
    }

    
}