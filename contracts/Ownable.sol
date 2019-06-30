pragma solidity ^0.5.0;

contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "you are not allowed to make this transaction");
        _;
    }

    function transferOwnership(address newOwner) public isOwner {
        require(newOwner != address(0),"you are not authorized to make this transaction");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}