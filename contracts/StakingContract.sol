pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract staking{
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt
        bool inBlackList;
    }

    struct PoolInfo {          
        uint256 allocPoint;      
        uint256 lastRewardBlock;  
        uint256 accRewardPerShare; 
    }

    // The REWARD TOKEN
    ERC20 public rewardToken;

    uint REWARD_MULTIPLIER=1;

    address public adminAddress;

    uint256 public rewardPerBlock;

    PoolInfo[] public poolInfo;

    mapping (address => UserInfo) public userInfo;
    uint256 public limitAmount = 10000000000000000000;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CAKE mining starts.
    uint256 public startBlock;
    // The block number when CAKE mining ends.
    uint256 public bonusEndBlock;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(
        ERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _adminAddress
    ) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        adminAddress = _adminAddress;

        // staking pool
        poolInfo.push(PoolInfo({
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accRewardPerShare: 0
        }));

        totalAllocPoint = 1000;
    }
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "You are not admin");
        _;
    }
    function setBlackList(address _blacklistAddress) public onlyAdmin {
        userInfo[_blacklistAddress].inBlackList = true;
    }
    function changeMultiplier(uint newMultiplier) public onlyAdmin{
        REWARD_MULTIPLIER=newMultiplier;
    }
    function removeBlackList(address _blacklistAddress) public onlyAdmin {
        userInfo[_blacklistAddress].inBlackList = false;
    }


    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        //uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock) {
            uint256 multiplier = REWARD_MULTIPLIER;
            uint256 cakeReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRewardPerShare = accRewardPerShare.add(cakeReward.mul(1e12));//.div(lpSupply));
        }
        return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        //uint256 lpSupply = pool.lpToken.balanceOf(address(this)); //getting balance of current contract from LP token provider contract
        // if (lpSupply == 0) {
        //     pool.lastRewardBlock = block.number;
        //     return;
        // }
        uint256 multiplier = REWARD_MULTIPLIER;
        uint256 cakeReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accRewardPerShare = pool.accRewardPerShare.add(cakeReward.mul(1e12));//.div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Stake tokens
    function depositToken() public payable {
        PoolInfo storage pool = poolInfo[0]; 
        UserInfo storage user = userInfo[msg.sender];

        require (user.amount.add(msg.value) <= limitAmount, 'exceed the top');
        require (!user.inBlackList, 'in black list');

        updatePool(0);
        // if (user.amount > 0) { //to be discussed
        //     uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        //     if(pending > 0) {
        //         rewardToken.safeTransfer(address(msg.sender), pending);
        //     }
        // }
        if(msg.value > 0) {
            safeTransferEth(address(this), msg.value);
            // assert(IWBNB(WBNB).transfer(address(this), msg.value));
            user.amount = user.amount.add(msg.value);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);

        emit Deposit(msg.sender, msg.value);
    }

    function safeTransferEth(address to, uint256 value) private {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        // (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function withdraw(uint256 _amount) payable public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0 && !user.inBlackList) {
            safeTransferEth(address(this), msg.value);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            safeTransferEth(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);

        emit Withdraw(msg.sender, _amount);
    }
}
