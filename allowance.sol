// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract allowance{
    receive() payable external{}
    address payable public allower= payable(msg.sender);
    struct request{
        string description;
        address myAdress;
        uint amountRequired;
    }
    event requestFulfilled(address _to, string _description,bool _amountallowed);
    mapping(uint=>request) public allRequest;
    uint reqnum;
    mapping(address=>uint) amountAllowed;

    modifier onlyOwner(){
        require(msg.sender==allower,"you are not the allower");
        _;
    }

    modifier notOwner(){
        require(msg.sender!=allower,"allower not allowed");
        _;
    }

    function requestAllowance(uint _amountRequired, string memory _description) public notOwner{
        request storage newRequest=allRequest[reqnum];
        reqnum++;
        newRequest.description=_description;
        newRequest.amountRequired=_amountRequired;
        newRequest.myAdress=msg.sender;
    }

    function fulfillRequest(uint _reqnum) onlyOwner public {        
        amountAllowed[allRequest[_reqnum].myAdress]=amountAllowed[allRequest[_reqnum].myAdress]+allRequest[_reqnum].amountRequired;
        emit requestFulfilled(allRequest[_reqnum].myAdress,allRequest[_reqnum].description,true);
    }

    function checkBalance() public view returns(uint){
        return address(this).balance;
    }

    function checkAllowance() public view notOwner returns(uint){
        return amountAllowed[msg.sender];
    }

    function withdrawMoney(uint _amt) public{
        require(amountAllowed[msg.sender]>=0&& amountAllowed[msg.sender]<=_amt || msg.sender==allower,"you do not have enough money to withdraw");
        require(address(this).balance>=_amt,"we do not have enough amount");
        payable(msg.sender).transfer(_amt);       
    }

}