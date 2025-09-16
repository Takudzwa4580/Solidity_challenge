// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSig {
    address public owner;
    address[] public subOwners;
    uint256 public trxnCount;

    uint256 public constant MAX_SUBOWNERS = 4;
    uint256 public constant REQUIRED = 3;

    struct Transaction {
        address to;
        address initiator;
        uint256 amount;
        bool executed;
        uint256 numConfirmations;
    }
    mapping(uint => Transaction) public transaction;
    mapping(uint => mapping(address => bool)) public confirmers;

    constructor() {
        owner = msg.sender;
        trxnCount = 0;
    }
    receive() external payable {}

    event SubOwnerAdded(address subOwner);
    event TrxnInitiated(
        uint256 id,
        address to,
        address initiator,
        uint256 amount
    );
    event TrxnConfirmed(uint256 id, address confirmer);
    event TrxnCompleted(uint256 _id, address to, address sender);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call");
        _;
    }
    modifier onlyOwnerAndSubOwners() {
        if (msg.sender == owner) {
            _;
            return;
        }
        for (uint256 i = 0; i < subOwners.length; i++) {
            if (subOwners[i] == msg.sender) {
                _;
                return;
            }
        }
        revert("only owner and subOwners can call");
    }

    function addSubOwners(address _subOwner) public onlyOwner {
        require(subOwners.length < MAX_SUBOWNERS, "SubOwners are full");
        for (uint256 i = 0; i < subOwners.length; i++) {
            if (subOwners[i] == _subOwner) {
                revert("already exist");
            }
        }
        subOwners.push(_subOwner);
        emit SubOwnerAdded(_subOwner);
    }

    function initiateTrxn(
        address _to,
        uint256 _amount
    ) public onlyOwnerAndSubOwners {
        require(_to != address(0), "Receiver Address invalid");
        require(_amount > 0, "amount invalid");
        trxnCount++;
        transaction[trxnCount] = Transaction({
            to: _to,
            initiator: msg.sender,
            amount: _amount,
            executed: false,
            numConfirmations: 1
        });
        emit TrxnInitiated(trxnCount, _to, msg.sender, _amount);
    }

    function confirmTrxn(uint _id) public onlyOwnerAndSubOwners returns (bool) {
        require(trxnCount >= _id, "transaction is not available");
        require(
            transaction[_id].executed == false,
            "Transacted already confirmed"
        );
        require(
            msg.sender != transaction[_id].initiator,
            " Transaction initiator cannot  confirm"
        );
        require(!confirmers[_id][msg.sender], "already confirmed");

        transaction[_id].numConfirmations++;
        confirmers[_id][msg.sender] = true;

        emit TrxnConfirmed(_id, msg.sender);

        return true;
    }

    function transferFunds(uint256 _id) public onlyOwnerAndSubOwners {
        require(
            transaction[_id].executed == false,
            "Transaction has already been executed"
        );
        require(
            transaction[_id].numConfirmations >= REQUIRED,
            "Not enough confirmations"
        );
        require(
            transaction[_id].amount < address(this).balance,
            "Not enough balance in the contract"
        );

        (bool send, ) = payable(transaction[_id].to).call{
            value: transaction[_id].amount
        }("");
        require(send, "transaction failed");

        transaction[_id].executed = true;

        emit TrxnCompleted(_id, transaction[_id].to, msg.sender);
    }

    function getPendingTrxns() public view returns (Transaction[] memory) {
        Transaction[] memory pendingTrxns = new Transaction[](trxnCount);
        for (uint256 i=1; i <= trxnCount; i++) {
            if (!transaction[i].executed) {
                pendingTrxns[i-1] = transaction[i];
            }
        }
        return pendingTrxns;
    }

    function getTrxnWithID(uint _id) public view returns (Transaction memory) {
        require(trxnCount >= _id, "transaction is not available");
        return transaction[_id];
    }

    function getallOwners() public view returns (address[] memory) {
        address[] memory allOwners = new address[](subOwners.length + 1);
        for(uint256 i=0; i < subOwners.length; i++){
            allOwners[i] = subOwners[i];
        }
        allOwners[subOwners.length] = owner;
        return allOwners;
    }

    function confCheck(uint _id,address _confirmer)public view returns(bool){
         return confirmers[_id][_confirmer];
    }
}
