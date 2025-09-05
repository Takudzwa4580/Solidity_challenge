//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract LotteryContract {
    address public owner;
    uint256 public ticketPrice;
    uint256 public raffleDuration;
    uint256 public maxTickets;
    uint256 public ticketSalesLaunchTime;
    address[] public participants;
    uint256 public totalTicketsSold;
    address public winner;
    uint256 public totalRevenue;
    uint256 public lotteryEndTime;
    address payable public devWallet;

    uint256 public constant DEV_FEE_PERCENT = 10; // 10% to dev
    mapping(address => bool) public hasTicket;

    enum LotteryStatus {
        Active,
        Ended,
        WinnerSelected,
        Completed
    }
    LotteryStatus public currentStatus;

    constructor(
        uint256 _ticketPrice,
        uint256 _raffleDuration,
        uint256 _maxTickets,
        uint256 _ticketSalesLaunchTime,
        address _devWallet
    ) {
        owner = msg.sender;
        devWallet = payable(_devWallet);
        ticketPrice = _ticketPrice;
        raffleDuration = _raffleDuration;
        maxTickets = _maxTickets;
        ticketSalesLaunchTime = _ticketSalesLaunchTime;
        lotteryEndTime = _ticketSalesLaunchTime + _raffleDuration;
        currentStatus = LotteryStatus.Active;
        totalTicketsSold = 0;
    }

    event TicketPurchased(address _buyer, uint256 _time);
    event WinnerSelected(address _winner, uint256 _time);
    event FundsDistributed(
        address _winner,
        uint256 _amount,
        address _devWallet,
        uint256 _devAmount,
        uint256 _time
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    modifier inState(LotteryStatus _currentStatus) {
        require(currentStatus == _currentStatus, "Invalid Lottery status");
        _;
    }

    function buyTicket() public payable inState(LotteryStatus.Active) {
        require(msg.value == ticketPrice, "Invalid Amount");
        require(totalTicketsSold < maxTickets, "No more available tickets");
        require(!hasTicket[msg.sender], "You already bought a ticket");
        require(block.timestamp < lotteryEndTime, "Lottery is over");
        participants.push(msg.sender);
        hasTicket[msg.sender] = true;
        totalTicketsSold++;
        totalRevenue += msg.value;

        emit TicketPurchased(msg.sender, block.timestamp);
    }

    function selectWinner() public onlyOwner inState(LotteryStatus.Ended) {
        require(totalTicketsSold > 0, "No Participants");

        uint256 randomIndex = uint256(
            (
                keccak256(
                    abi.encode(
                        block.timestamp,
                        block.prevrandao,
                        ticketPrice,
                        participants.length
                    )
                )
            )
        ) % participants.length;

        winner = participants[randomIndex];
        currentStatus = LotteryStatus.WinnerSelected;
        emit WinnerSelected(winner, block.timestamp);
    }

    function distributeFunds()
        public
        onlyOwner
        inState(LotteryStatus.WinnerSelected)
    {
        uint256 amount = (address(this).balance * (100 - DEV_FEE_PERCENT)) /
            100;
        payable(winner).transfer(amount);

        uint256 devAmount = (address(this).balance);
        payable(devWallet).transfer(devAmount);

        currentStatus = LotteryStatus.Completed;
        emit FundsDistributed(
            winner,
            amount,
            devWallet,
            devAmount,
            block.timestamp
        );
    }

    function endLottery() public onlyOwner inState(LotteryStatus.Active) {
        require(
            totalTicketsSold == maxTickets || block.timestamp >= lotteryEndTime,
            "Lottery is still active and has available tickets"
        );
        currentStatus = LotteryStatus.Ended;
    }

    function getRemainingTime()
        public
        view
        inState(LotteryStatus.Active)
        returns (uint256)
    {
        if (block.timestamp >= lotteryEndTime) {
            return 0;
        }
        return lotteryEndTime - block.timestamp;
    }

    function getLotteryStatus() public view returns (LotteryStatus) {
        return currentStatus;
    }

    function getParticipantsCount() public view returns (uint256) {
        return participants.length;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    function hasParticipant(address _user) public view returns (bool) {
        return hasTicket[_user];
    }
}
