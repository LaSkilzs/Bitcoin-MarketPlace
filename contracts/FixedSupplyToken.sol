pragma solidity ^0.5.0;
import "contracts/ERC20Interface.sol";


contract FixedSupplyToken is ERC20Interface {
    string public name = "Example FIXED supply";
    string public symbol = "FIXED";
    uint8 public decimals = 10;
    uint _totalSupply = 1000000;

    address public _owner;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    constructor()public{
        _owner = msg.sender;
        balances[_owner] = _totalSupply;
    }

    function totalSupply() external view returns(uint) {
        return _totalSupply;
    }

    function balanceOf(address owner) external view returns(uint){
        return balances[owner];
    }

    function transfer(address to, uint value) external returns(bool success){
        require(balances[msg.sender] >= value, "not Enough to make transfer");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool success){
        uint allowance = allowed[from][msg.sender];
        require(balances[msg.sender] >= value && allowance >= value,"not Enough to make transfer");
        allowed[from][msg.sender] -= value;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) external returns(bool success){
        require(spender != msg.sender, "not Enough to make transfer");
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns(uint) {
        return allowed[owner][spender];
    }
}