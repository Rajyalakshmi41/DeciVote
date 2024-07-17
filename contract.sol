// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract vote{

    //1st entity
    struct Voter{

        string name;
        uint age;
        uint voterId;
        Gender gender;
        uint voteCandidateId; //candidate Id to whom the voter has voted
        address voterAddress; //Voter EOA

    }
    //2nd entity
    struct Candidate{

        string name;
        string party ;
        uint age;
        Gender gender;
        uint CandidateId;
        address candidateAddress; //candidate EOA
        uint votes; //no. of votes

    }
    //3rd entity
    address electionCommission;


    address public winner;
    uint nextVoterId =1;
    uint nextCandidateId= 1;

    //voting Period
    uint startTime;
    uint endTime;
    bool stopVoting;

    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;

    enum VotingStatus {NotStarted, InProgress,Ended}
    enum Gender {NotSpecified, Make, Female, Other}

    constructor() {
        electionCommission = msg.sender;
    }

    modifier isVotingOver() {

        require(block.timestamp<=endTime && stopVoting == false, "Voting is Over");
        _;
    }

     modifier onlyCommissioner() {

        require(msg.sender == electionCommission, "Not authorized");
        _;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    ) external {
        require(_age>=18, "You are below 18");
        require(isCandidateNotRegistered(msg.sender), "you are already registered");
        require(nextCandidateId<3, "Candidate Registration Full");
        require(msg.sender!=electionCommission, "Election commission cannot register as a candidate");
        candidateDetails[nextCandidateId] = Candidate(
            {
                name: _name,
                party: _party,
                age: _age,
                gender:  _gender,
                CandidateId: nextCandidateId,
                candidateAddress:  msg.sender,
                votes: 0

            }
            
            
            
           
            
           
            
        );
        nextCandidateId++;

    }
    

    function isCandidateNotRegistered(address _person) internal view returns (bool){
        for(uint i=1;i<nextCandidateId;i++){
            if(candidateDetails[i].candidateAddress== _person){
                return false;
            }
        }
        return true;

    }

    function getCandidateList() public view returns (Candidate[] memory) {

        Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1);
        for(uint i=0; i < candidateList.length;i++){
            candidateList[i] = candidateDetails[i + 1];
        }
        return candidateList;
        
    }

    function isVoterNotRegistered(address _person) private view returns (bool){
        for(uint i=1;i<nextVoterId;i++){
            if(voterDetails[i].voterAddress== _person){
                return false;}
        }

        return true;
        
    }

    function registerVoter(
        string calldata _name,
        uint _age,
        Gender _gender

    )external {
        require(_age>=18, "You are below 18");
        require(isVoterNotRegistered(msg.sender)," You are already registered"); //checks
        

        voterDetails[nextVoterId] = Voter( {  
            name: _name,
            age: _age,
            voterId: nextVoterId,
            gender: _gender,
            voteCandidateId : 0,
            voterAddress: msg.sender
            });
            nextVoterId++;
        }


    


    function getVoterList() public view returns (Voter[] memory){
        Voter[] memory voterList = new Voter[](nextVoterId - 1);
        for(uint i =0 ; i < voterList.length; i++){
            voterList[i] = voterDetails[i+ 1 ];
        }
        return voterList;
    }

    function castVote(uint _voterId, uint _candidateId) external{
        require(voterDetails[_voterId].voteCandidateId==0,"you have already Voted");
        require(voterDetails[_voterId].voterAddress == msg.sender,"you are not authorized");
        require(_candidateId>=1 && _candidateId <3, "candidate Id is not correct");
        voterDetails[_voterId].voteCandidateId = _candidateId; //voting to _candidateId
        candidateDetails[_candidateId].votes++; //icrement _candidateId votes



        
    }

    function setVotingPeriod(uint _startTimeDuration, uint _endTimeDuration) external onlyCommissioner (){
        require(_endTimeDuration >3600, "_endTimeDuration must be greater than 1 hour");
        startTime = block.timestamp+_startTimeDuration;
        endTime = startTime+_endTimeDuration;
        
    }

    function getVotingStatus()public view returns (VotingStatus){
        if(startTime==0){
            return VotingStatus.NotStarted;

        }else if(endTime>block.timestamp && stopVoting==false){
            return VotingStatus.InProgress;
         }else {
            return VotingStatus.Ended;
        }
    }

    function announceVotingResult() external onlyCommissioner (){
        uint max=0;
        for(uint i=1; i<nextCandidateId; i++){
            if(candidateDetails[i].votes>max){
                max=candidateDetails[i].votes;
                winner= candidateDetails[i].candidateAddress ;
            }
        }
        
        
    }

    function emergencyStopVoting() public onlyCommissioner (){
        stopVoting =true;
        
    }

     





}

