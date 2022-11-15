// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct player{
    address payable playerAddress;
    uint Value;
}

contract auction{
    uint public basePrice;
    uint public variation;
    uint highestPayableBid;
    address winnerAddress;
    uint highestBid;
    address payable auctioneer = payable(msg.sender);
    player[] _players;

    modifier onlyOwner(){
        require(msg.sender==auctioneer,"only auctioneer can control");
        _;
    }
    modifier notOwner(){
        require(msg.sender!=auctioneer,"auctioneer cannot participate");
        _;
    }
    constructor(uint _basePrice, uint _variation){
        basePrice=_basePrice * (10 ** 18);
        variation=_variation* (10 ** 18);
    }

    function alreadyMember() view private returns(bool) {
        for (uint i=0;i<_players.length;i++){
            if (_players[i].playerAddress==msg.sender){
                return true ;
                }
            }
            return false;
    }

    function enter() public payable notOwner {
        require(msg.value>=basePrice ,"minimum requirement is base Price");
        require(alreadyMember()==false,"can not enter twice");
        _players.push(player(payable(msg.sender),msg.value));
    }

    function extendBid() public payable notOwner{
        for(uint i=0;i<_players.length;i++){
            if(msg.sender==_players[i].playerAddress){
                _players[i].Value= _players[i].Value+msg.value;
            }
        }
    }

    function quitAuction() public notOwner payable{
        for(uint i=0;i<_players.length;i++){
            if (msg.sender==_players[i].playerAddress){
                _players[i].playerAddress.transfer(_players[i].Value);
                delete _players[i];
            }
        }
    }

    function cancelAuction() public onlyOwner payable{
        for(uint i=0;i<_players.length;i++){
            _players[i].playerAddress.transfer(_players[i].Value);
        }
        delete _players;
    }

    function pickWinner() public onlyOwner{
        for(uint i=0;i<_players.length;i++){
            if(highestBid<_players[i].Value){
            winnerAddress=_players[i].playerAddress;
            highestBid=_players[i].Value;
            }
        }
        for(uint i=0;i<_players.length;i++){
            if(highestPayableBid<_players[i].Value){
                if(_players[i].Value==highestBid){
                    continue;
                }
            highestPayableBid=_players[i].Value;
            }
        }
        highestPayableBid=highestPayableBid+variation;
    }

    function endAuction() public payable onlyOwner{
        auctioneer.transfer(highestPayableBid);
        payable(winnerAddress).transfer(highestBid-highestPayableBid);
        for(uint i=0;i<_players.length;i++){
            if(_players[i].playerAddress==winnerAddress){
                continue;
            }
            _players[i].playerAddress.transfer(_players[i].Value);
        }
        delete _players;
        highestBid=0;
        highestPayableBid=0;
        winnerAddress=address(0);
        
    }
}