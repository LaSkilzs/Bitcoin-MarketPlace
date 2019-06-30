pragma solidity ^0.5.0;

interface ERC20Interface {
    function totalSupply() external view returns(uint);
    function balanceOf(address owner)  external view returns(uint256 balance);
    function transfer(address to, uint value) external returns(bool success);
    function transferFrom(address _from, address _to, uint256 value)  external returns(bool success);
    function approve(address spender, uint256 value)  external returns(bool success);
    function allowance(address owner, address spender)  external view returns(uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}