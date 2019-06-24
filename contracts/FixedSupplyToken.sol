pragma solidity ^0.5.0;

interface ERC20Interface {
    function transfer(address to, uint tokens) external returns(bool success);
    function transferFrom(address from, address tokenOwner)  external returns(bool success);
    function balanceOf(address tokenOwner)  external view returns(uint balance);
    function approve(address spender, uint tokens)  external returns(bool success);
    function allowance(address tokenHolder, address spender)  external view returns(uint);
    function totalSupply() external view returns(uint);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ERC20Token is ERC20Interface {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }

    function transfer(address to, uint value) external returns(bool){
        require(balances[msg.sender] >= value, "not Enough to make transfer");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool){
        uint allowance = allowed[from][msg.sender];
        require(balances[msg.sender] >= value && allowance >= value,"not Enough to make transfer");
        allowed[from][msg.sender] -= value;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) external returns(bool){
        require(spender != msg.sender, "not Enough to make transfer");
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns(uint) {
        return allowed[owner][spender];
    }

    function balanceOf(address owner) external view returns(uint){
        return balances[owner];

    }

    function _mint(address account, uint amount) internal{
        require(account == msg.sender, "invalid account");
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal{
        require(account == msg.sender, 'invalid account');
        require(amount <= balances[account],'invalid account');
        totalSupply -= amount;
        balances[account] -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint amount) internal{
        require(amount <= allowed[account][msg.sender], "not valid address");        allowed[account][msg.sender] -= amount;
        _burn(account, amount);
    }

    function increaseAllowance(address spender, uint addedValue) public returns(bool){
        require(spender != address(0), "not valid address");
        allowed[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool){
        require(spender != address(0), "not valid address");
        allowed[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
}