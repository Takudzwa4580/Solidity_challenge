// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract TokenStaking {
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 lockPeriod;
        uint256 lastRewardCalculation;
    }
    IERC20 public stakingToken;
    uint256 public rewardRate;
    uint256 public penaltyRate;
    mapping(address => Stake) public stakes;
    event Staked(address indexed user, uint256 amount, uint256 lockPeriod);
    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 reward,
        uint256 penalty
    );

    constructor(
        address _stakingToken,
        uint256 _rewardRate,
        uint256 _penaltyRate
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
        penaltyRate = _penaltyRate;
    }

    modifier noActiveStake() {
        require(stakes[msg.sender].amount == 0, "Already have active stake");
        _;
    }

    modifier hasActiveStake() {
        require(stakes[msg.sender].amount > 0, "No active stake");
        _;
    }

    function stake(uint256 _amount, uint256 _lockPeriod) public noActiveStake {
        require(_amount > 0, "invalid stake");
        require(
            _lockPeriod >= 1 days && _lockPeriod <= 365 days,
            "Invalid lock period"
        );

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = Stake({
            amount: _amount,
            timestamp: block.timestamp,
            lockPeriod: _lockPeriod,
            lastRewardCalculation: block.timestamp
        });
        emit Staked(msg.sender, _amount, _lockPeriod);
    }

    function calculateReward(address _user) public view returns (uint256) {
        Stake memory userStake = stakes[_user];
        if (stakes[_user].amount == 0) {
            return 0;
        }
        uint256 timeStaked = block.timestamp - userStake.lastRewardCalculation;
        uint256 reward = (userStake.amount * rewardRate * timeStaked) /
            (365 days * 10000);
        return reward;
    }

    function isLocked(address _user) public view returns (bool) {
        return (block.timestamp <
            stakes[_user].timestamp + stakes[_user].lockPeriod);
    }

    function withdraw() public hasActiveStake {
        uint256 stakedAmount = stakes[msg.sender].amount;
        uint256 reward = calculateReward(msg.sender);
        uint256 penalty = 0;

        if (isLocked(msg.sender)) {
            penalty = (stakedAmount * penaltyRate) / 10000;
        }

        uint256 totalAmount = stakedAmount + reward - penalty;

        delete stakes[msg.sender];

        stakingToken.transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, stakedAmount, reward, penalty);
    }
}
