// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Candidate {
        string name;
        uint256 voteCount;
    }
    mapping(uint256 => Candidate) public candidateToID;
    mapping(address => bool) public candidateVote;

    uint256 public candidatesCount;
    address public owner;

    constructor() {
        owner = msg.sender;
        candidatesCount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner is allowed");
        _;
    }
    modifier onlyValid(uint256 _candidateId) {
        require(
            0 < _candidateId && candidatesCount >= _candidateId ,
            "candidateId is not valid"
        );
        _;
    }

    function addCandidate(string memory _candidateName) public onlyOwner {
        candidatesCount++;
        candidateToID[candidatesCount] = Candidate({
            name: _candidateName,
            voteCount: 0
        });
    }

    function vote(uint256 _candidateId) public onlyValid(_candidateId) {
        require(!candidateVote[msg.sender], "has already voted");

        candidateVote[msg.sender] = true;
        candidateToID[_candidateId].voteCount++;
    }

    function getCandidate(uint256 _candidateId)
        public
        view
        onlyValid(_candidateId)
        returns (string memory, uint256)
    {
        return (
            candidateToID[_candidateId].name,
            candidateToID[_candidateId].voteCount
        );
    }

 function getWinner()public view returns(string memory,uint){
    require(candidatesCount >=1,"not enough candidates");
    uint  winnerId=1;
    uint winnerCount;
    for(uint i=1;i<=candidatesCount;i++){
        if(candidateToID[i].voteCount > winnerCount){
            winnerId = i;
            winnerCount = candidateToID[i].voteCount;
        }
        }
        return (candidateToID[winnerId].name,candidateToID[winnerId].voteCount);
 }

}
