// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract crowdFunding{
    address public owner;
    uint public goal;
    uint public minimumAmount;
    mapping(address =>uint ) fund;
    uint public noOfFunders;
    uint public fundsRaised;
    uint public timePeriod;

    constructor(uint _timeperiod,uint _minimumValue, uint _goal){
        owner=msg.sender;
        noOfFunders=0;
        fundsRaised=0;
        timePeriod=block.timestamp+_timeperiod;
        minimumAmount=_minimumValue;
        goal=_goal;
    }

    modifier notOwner(){
        require(msg.sender!=owner,"owner cannot enter");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"only owner can use this");
        _;
    }

    function raise() public notOwner payable{
        require(msg.value>=minimumAmount,"amount less than minimum amount");
        require(block.timestamp<timePeriod,"time's up");
        if(fund[msg.sender]==0){
            noOfFunders++;
        }
        fund[msg.sender]=fund[msg.sender]+msg.value;
        fundsRaised=fundsRaised+msg.value;
    }

    function getMoneyBack() public {
        require(block.timestamp>timePeriod,"time is not up");
        require(fundsRaised<goal,"goal is already completed");
        require(fund[msg.sender]>=0,"you do not have any money here");
        payable(msg.sender).transfer(fund[msg.sender]);
        fundsRaised=fundsRaised-fund[msg.sender];
        noOfFunders--;
        fund[msg.sender]=0;
    }

    struct request{
        string description;
        address payable to;
        uint amount;
        uint noOfVoters;
        mapping(address=>bool) votes;
        bool completed;
    }

    mapping(uint=>request) public allRequest ;
    uint numreq;
    function createRequest(string memory  _description,address payable _to,uint _amt) public onlyOwner {
        request storage thisRequest=allRequest[numreq];
        numreq++;
        thisRequest.description=_description;
        thisRequest.to=_to;
        thisRequest.amount=_amt;
        thisRequest.noOfVoters=0;
        thisRequest.completed=false;
    }

    function voting(uint _reqnum) public{
        require(fund[msg.sender]>=0,"you cannot vote, not a funder");
        require(allRequest[_reqnum].votes[msg.sender]==false,"already voted");
        require(allRequest[_reqnum].completed==false,"money already given");
        allRequest[_reqnum].votes[msg.sender]=true;
        allRequest[_reqnum].noOfVoters++;
    }

    function pay(uint _reqnum) public {
        if(allRequest[_reqnum].noOfVoters>=noOfFunders/2){
            payable(allRequest[_reqnum].to).transfer(allRequest[_reqnum].amount);
            allRequest[_reqnum].completed=true;
            fundsRaised=fundsRaised- allRequest[_reqnum].amount;
        }
    }
}



