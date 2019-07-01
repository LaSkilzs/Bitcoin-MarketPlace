pragma solidity ^0.5.0;

import "contracts/Ownable.sol";
import "contracts/FixedSupplyToken.sol";

contract Exchange is Ownable{


    struct Offer{
        uint amount;
        address who;
    }

    struct OrderBook{
        uint higherPrice;
        uint lowerPrice;

        mapping(uint => Offer)offers;

        uint offers_key;
        uint offers_length;
    }

    struct Token{
        address tokenContract;
        string symbolName;

        mapping(uint => OrderBook) buyBook;
        uint currrentBuyPrice;
        uint lowestBuyPrice;
        uint amountBuyPrices;

        mapping(uint => OrderBook) sellBook;
        uint currrentSellPrice;
        uint highestSellPrice;
        uint amountSellPrices;
    }

    mapping(uint8 => Token)token;
    uint8 symbolNameIndex;

    //Balances
    mapping(address => mapping(uint8 => uint)) tokenBalForAddress;
    mapping(address => uint) balanceEthForAddress;

    // Ethereum Management
    function depositEther()external payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender], "Invalid Ether Amount");
        balanceEthForAddress[msg.sender] += msg.value;
    }

    function withdrawEther(uint amountInWei) external{
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0, 'Invalid Amount');
        require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender], 'Invalid Amount');
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
    }
    function getEthBalanceInWei() external view returns(uint){
        return balanceEthForAddress[msg.sender];
    }


    // Token Management
    function addToken(string memory symbolName, address erc20TokenAddress) public{
        require(!hasToken(symbolName), "can't add Token");
        symbolNameIndex++;
        token[symbolNameIndex].tokenContract = erc20TokenAddress;
        token[symbolNameIndex].symbolName = symbolName;
    }
    function hasToken(string memory symbolName) public view returns(bool){
        uint8 index = getSymbolIndex(symbolName);
        if(index == 0){
            return false;
        }
        return true;
    }
    function getSymbolIndex(string memory symbolName) public view returns(uint8){
        for(uint8 i = 1; i <= symbolNameIndex; i++){
            if(stringsEqual(token[i].symbolName, symbolName)){
                return i;
            }
        }
        return 0;
    }
    function stringsEqual(string storage _a, string memory _b) internal view returns(bool){
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if(a.length != b.length)
        return false;
        for(uint i = 0; i < a.length; i++){
            if(a[i] != b[i]) {return false;}
        }
        return true;
    }

    //General Functionality
    function depositToken(string memory symbolName, uint amount) public{
        symbolNameIndex = getSymbolIndex(symbolName);
        require(symbolNameIndex > 0, 'no token contract available');
        require(token[symbolNameIndex].tokenContract != address(0), "wrong user");

        ERC20Interface tokens = ERC20Interface(token[symbolNameIndex].tokenContract);

        require(tokens.transferFrom(msg.sender, address(this), amount) == true, 'error with transfer');
        require(tokenBalForAddress[msg.sender][symbolNameIndex] + amount >= tokenBalForAddress[msg.sender][symbolNameIndex], 'invalid balance');
        tokenBalForAddress[msg.sender][symbolNameIndex] += amount;
    }

    function withdrawToken(string memory symbolName, uint amount) public{
        symbolNameIndex = getSymbolIndex(symbolName);
        require(token[symbolNameIndex].tokenContract != address(0), 'can not locate tokenContract');
        require(symbolNameIndex > 0, 'no token contract available');

        ERC20Interface tokens = ERC20Interface(token[symbolNameIndex].tokenContract);

        require(tokenBalForAddress[msg.sender][symbolNameIndex] - amount >= 0, 'invalid amount');
        require(tokenBalForAddress[msg.sender][symbolNameIndex] - amount <= tokenBalForAddress[msg.sender][symbolNameIndex], "invalid amount");

        tokenBalForAddress[msg.sender][symbolNameIndex] -= amount;
        require(tokens.transfer(msg.sender, amount) == true, "invalid request");
    }

    function getBalance(string memory symbolName) public returns(uint){
        symbolNameIndex = getSymbolIndex(symbolName);
        require(symbolNameIndex > 0, 'No Token Contract');
        return tokenBalForAddress[msg.sender][symbolNameIndex];
    }

                          // OrderBook //

    //Bid Orders
    function getBuyOrderBook(string memory symbolName) public returns(uint[] memory,uint[] memory){}

    //Ask Orders
    function getSellOrderBook(string memory symbolName) public returns(uint[] memory, uint[] memory){}

    //New Bid Order
    function buyToken(string memory symbolName, uint priceInWei, uint amount) public{}

    //New Ask Order
    function sellToken(string memory symbolName, uint priceInWei, uint amount) public{}

    //Cancel Limit Order
    function cancelOrder(string memory symbolName, uint priceInWei, uint amount, uint offer_key) public{}

}
