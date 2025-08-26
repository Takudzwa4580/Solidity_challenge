// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAuction {
    address payable public beneficiary;
    uint256 public endTime;
    uint256 public highestBid;
    address payable public highestBidder;
    bool public endedStatus;
    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    constructor(uint256 _biddingTime, address payable _beneficiary) {
        endTime = block.timestamp + _biddingTime;
        beneficiary = _beneficiary;
    }

    mapping(address => uint256) public pendingReturns;

    function bid() external payable {
        require(block.timestamp < endTime, "Auction already ended");
        require(msg.value > highestBid, "There already is a higher bid");
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = payable(msg.sender);
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No Funds to withdraw");
        pendingReturns[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function auctionEnd() external {
        require(block.timestamp >= endTime, "Auction has not yet ended");
        require(!endedStatus, "Auction already ended");
        endedStatus = true;
        beneficiary.transfer(highestBid);
        emit AuctionEnded(highestBidder, highestBid);
    }

    function getAuctionInfo()
        external
        view
        returns (
            uint256,
            address,
            uint256,
            bool
        )
    {
        return (highestBid, highestBidder, endTime, endedStatus);
    }

    function getRemainingTime() public view returns (uint256) {
        if (block.timestamp >= endTime) {
            return 0;
        }
        return (endTime - block.timestamp);
    }

    function getHighestBidder() public view returns (address payable) {
        return highestBidder;
    }
}
