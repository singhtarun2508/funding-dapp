// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract funder{

    uint public no;
    mapping(uint=>address)public  funders;

    receive() external payable{}

    function fundTransfer() public payable{
        funders[no]=msg.sender;
        no++;
    }

    function withdraw() public {
        payable(msg.sender).transfer(1*10**18);
    }

}