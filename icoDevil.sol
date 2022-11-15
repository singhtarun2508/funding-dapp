// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC_20{
    function name() external view  returns (string memory);
    function symbol() external view   returns (string memory);
    function decimals() external view   returns (uint8);
    function totalSupply() external view   returns (uint256);
    function balanceOf(address _owner) external view   returns (uint256 balance);
    function transfer(address _to, uint256 _value) external   returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external   returns (bool success);
    function allowance(address _owner, address _spender) external view   returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract devil is ERC_20{

    string _name;
    string _symbol;
    uint8 _decimal;
    uint256 _totalSupply;
    mapping(address=>uint) _balanceOf;
    mapping(address=> mapping(address=>uint)) _allowance;

    constructor(){
        _name="devil";
        _symbol="DEV";
        _decimal=18;
        _totalSupply=1000000;
        _balanceOf[msg.sender]=_totalSupply;
        _allowance[msg.sender][address(0)]=0;
        emit Transfer(address(0),msg.sender,_totalSupply);
    }

    function name() public override view returns (string memory){
        return _name;
    }

    function symbol() public override view returns (string memory){
        return _symbol;
    }

    function decimals() public override view returns (uint8){
        return _decimal;
    }

    function totalSupply() public override view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance){
        return _balanceOf[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success){
        _allowance[msg.sender][_spender]=_value;
        emit Approval(msg.sender,_spender,_value);
        success=true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining){
        return _allowance[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success){
        require(_balanceOf[_from]<=_value&& _allowance[_from][_to]>=_value);
        _balanceOf[_from]-=_value;
        _balanceOf[_to]+=_value;
        _allowance[_from][_to]-=_value;
        emit Transfer(_from,_to,_value);
        return true;
    }

    function transfer(address _to, uint256 _value) public override virtual returns (bool success){
        transferFrom(msg.sender,_to,_value);
        return true;
    }

}

contract ico is devil{
    address public owner;
    uint public starttime;
    uint public endtime;
    uint noOfToken;
    uint public tokenPrice=10000000000000000;
    uint public minimumPurchase=1;
    uint maximumPurchase=5000;

    enum status {active, inactive,completed}
    status public Status;

    constructor(){
        owner=msg.sender;
        starttime=block.timestamp;
        endtime=starttime+172800;
        Status=status.active;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"you are not the owner");
        _;
    }

    function resume() public onlyOwner{
        require(block.timestamp>=starttime && block.timestamp<=endtime,"time ended, cannot be resumed");        
        Status=status.active;
    }

    function pause() public onlyOwner{
        Status=status.inactive;
    }

    function completed() private{
        if(block.timestamp<=endtime){
        Status=status.completed;
        }
    }

    function getStatus() public returns(status){
        completed();
        return(Status);
    }

    function buy() payable public{
        completed();
        require(Status==status.active,"The ICO is not in active state");
        require(block.timestamp>=starttime && block.timestamp<=endtime,"time ended");
        require(msg.value>=minimumPurchase*10000000000000000,"minimum purchase limit is 1 token");
        require(msg.value>=maximumPurchase*10000000000000000,"maximum purchase limit is 5000 token");
        payable(owner).transfer(msg.value);
        noOfToken=msg.value/tokenPrice;
        _balanceOf[owner]-=noOfToken;
        _balanceOf[msg.sender]+=noOfToken;
        emit Transfer(owner,msg.sender,noOfToken);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        require(Status==status.completed,"Please wait for ICO to finish");
        super.transferFrom(_from,_to,_value);
        return true;
    }

    function transfer(address _to, uint256 _value) public override virtual returns (bool success){
        require(Status==status.completed,"Please wait for ICO to finish");
        super.transfer(_to,_value);
        return true;
    }

}