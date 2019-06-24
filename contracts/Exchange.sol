pragma solidity ^0.5.0;

import "./Owned.sol";
import "./FixedSupplyToken.sol";

contract Exchange is Owned{


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
    mapping(address => mapping(uint8 => uint)) tokenBalanceForAddress;
    mapping(address => uint) balanceEthForAddress;

    // Ethereum Management
    function depositEther()external payable{}
    function withdrawEther(uint amountInWei) external{}
    function getEthBalanceInWei() external returns(uint){}

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
    function depositToken(string memory symbolName, uint amount) public{}
    function withdrawToken(string memory symbolName, uint amount) public{}
    function getBalance(string memory symbolName) public returns(uint){}

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
