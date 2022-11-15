// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract lottery{

    address payable private manager = payable(msg.sender);
    address payable[] public players;   


    modifier onlyOwner {
        require(msg.sender==manager,"only manager can control");  
        _;      
    }
    function alreadyMember() view private returns(bool) {
        for (uint i=0;i<players.length;i++){
            if (players[i]==msg.sender){
                return true ;
            }
        }
        return false;

    }

    function enter() public payable {
        require(msg.sender!=manager,"manager can not participate");
        // if(alreadyMember()==true){
        //     revert("can not participate twice");
        //     }
        require(alreadyMember()==false,"can not participate twice");
        require(msg.value>=1 ether,"minimum 1 ether required");
        players.push(payable(msg.sender));
    }

    function random() private view returns(uint){

        return uint(keccak256(abi.encodePacked(players.length,manager,block.difficulty)));
    }
     
    function pickWinner() public payable onlyOwner{
        uint winner= random()%players.length;
        players[winner].transfer(address(this).balance);
        players= new address payable[](0);
    }


    function checkBalance() public view returns(uint){
        return address(this).balance;
    }
}