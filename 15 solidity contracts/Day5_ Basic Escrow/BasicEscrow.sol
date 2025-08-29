// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicEscrow {
    address payable public buyer;
    address payable public seller;
    address public arbiter;
    uint256 public amount;
    Status public status;

    event FundsDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller);
    event FundsReleased(address indexed seller, uint256 amount);
    event DisputeRaised(address indexed buyer, address indexed seller);
    event DisputeResolved(address indexed victim, uint256 amount);
    event Refunded(address indexed beneficiary, uint256 amount);

    enum Status {
        Created,
        Funded,
        Delivered,
        Disputed,
        Released,
        Refunded
    }

    constructor(
        address _buyer,
        address _seller,
        address _arbiter
    ) {
        require(_buyer != address(0), "Invalid buyer address");
        require(_seller != address(0), "Invalid seller address");
        require(_arbiter != address(0), "Invalid arbiter address");
        require(_buyer != _seller, "Buyer and seller must be different");
        require(
            _buyer != _arbiter && _seller != _arbiter,
            "Arbiter must be different from parties"
        );

        buyer = payable(_buyer);
        seller = payable(_seller);
        arbiter = _arbiter;
        status = Status.Created;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call");
        _;
    }

    modifier inState(Status _status) {
        require(status == _status, "Invalid status");
        _;
    }

    modifier onlyParties() {
        require(
            msg.sender == buyer || msg.sender == seller,
            "Only buyers and sellers can call"
        );
        _;
    }

    function depositFunds() external payable inState(Status.Created) onlyBuyer {
        require(msg.value > 0, "Must deposit some funds");
        amount = msg.value;
        status = Status.Funded;
        emit FundsDeposited(buyer, amount);
    }

    function confirmDelivery() external inState(Status.Funded) onlyBuyer {
        status = Status.Delivered;
        emit DeliveryConfirmed(buyer, seller);
    }

    function releaseFunds() external inState(Status.Delivered) onlyBuyer {
        uint256 transferAmount = amount;
        amount = 0;

        (bool success, ) = seller.call{value: transferAmount}("");
        require(success, "Transfer failed");

        status = Status.Released;
        emit FundsReleased(seller, transferAmount);
    }

    function raiseDispute() external onlyParties {
        require(
            status == Status.Funded || status == Status.Delivered,
            "Can only dispute in Funded or Delivered state"
        );
        status = Status.Disputed;
        emit DisputeRaised(buyer, seller);
    }

    function resolveDispute(address _victim)
        external
        onlyArbiter
        inState(Status.Disputed)
    {
        require(
            _victim == buyer || _victim == seller,
            "Invalid victim address"
        );

        uint256 transferAmount = amount;
        amount = 0;

        address payable recipient = payable(_victim);
        (bool success, ) = recipient.call{value: transferAmount}("");
        require(success, "Transfer failed");

        if (_victim == buyer) {
            status = Status.Refunded;
        } else {
            status = Status.Released;
        }

        emit DisputeResolved(_victim, transferAmount);
    }

    function refund(address payable _beneficiary)
        external
        onlyArbiter
        inState(Status.Disputed)
    {
        require(
            _beneficiary == buyer || _beneficiary == seller,
            "Invalid beneficiary address"
        );

        uint256 transferAmount = amount;
        amount = 0;

        (bool success, ) = _beneficiary.call{value: transferAmount}("");
        require(success, "Transfer failed");

        if (_beneficiary == buyer) {
            status = Status.Refunded;
        } else {
            status = Status.Released;
        }

        emit Refunded(_beneficiary, transferAmount);
    }

    function emergencyWithdraw() external onlyArbiter {
        require(address(this).balance > 0, "No funds to withdraw");
        require(
            status == Status.Released || status == Status.Refunded,
            "Cannot withdraw unless dispute is resolved"
        );

        uint256 leftoverAmount = address(this).balance;
        (bool success, ) = payable(arbiter).call{value: leftoverAmount}("");
        require(success, "Emergency withdrawal failed");
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getStatus() external view returns (Status) {
        return status;
    }

    function getContractDetails()
        external
        view
        returns (
            address _buyer,
            address _seller,
            address _arbiter,
            uint256 _amount,
            Status _status
        )
    {
        return (buyer, seller, arbiter, amount, status);
    }

    function isFinalized() external view returns (bool) {
        return status == Status.Released || status == Status.Refunded;
    }
}
