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
        uint currentBuyPrice;
        uint lowestBuyPrice;
        uint amountBuyPrices;

        mapping(uint => OrderBook) sellBook;
        uint currentSellPrice;
        uint highestSellPrice;
        uint amountSellPrices;
    }

    mapping(uint8 => Token)token;
    uint8 symbolNameIndex;

    // Management events
    event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);

    // Deposit/Withdrawal events
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event WithdrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    // Trading/Order Events
    event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
    event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event SellOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

    event LimitBuyOrderCreated(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event BuyOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event BuyOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

    //Balances
    mapping(address => mapping(uint8 => uint)) tokenBalForAddress;
    mapping(address => uint) balanceEthForAddress;

    // Ethereum Management
    function depositEther()external payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender], "Invalid Ether Amount");
        balanceEthForAddress[msg.sender] += msg.value;
        emit DepositForEthReceived(msg.sender, msg.value, now);
    }
    function withdrawEther(uint amountInWei) external{
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0, 'Invalid Amount');
        require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender], 'Invalid Amount');
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
        emit WithdrawalEth(msg.sender, amountInWei, now);
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
        emit TokenAddedToSystem(symbolNameIndex, symbolName, now);
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
        require(keccak256(a) == keccak256(b),"Strings are not Equal");
        if(a.length != b.length) {
            return false;
        } else {
            return true;
        }
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
        emit DepositForTokenReceived(msg.sender, symbolNameIndex, amount, now);
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
        emit WithdrawalToken(msg.sender, symbolNameIndex, amount, now);
    }
    function getBalance(string memory symbolName) public returns(uint){
        symbolNameIndex = getSymbolIndex(symbolName);
        require(symbolNameIndex > 0, 'No Token Contract');
        return tokenBalForAddress[msg.sender][symbolNameIndex];
    }

                            // OrderBook //

    //Bid Orders
    function getBuyOrderBook(string memory symbolName) public returns(uint[] memory,uint[] memory){
        uint8 tokenNameIndex = getSymbolIndex(symbolName);
        uint[] memory arrPriceBuy = new uint[](token[tokenNameIndex].amountBuyPrices);
        uint[] memory arrVolumeBuy = new uint[](token[tokenNameIndex].amountBuyPrices);

        uint whilePrice = token[tokenNameIndex].lowestBuyPrice;
        uint counter = 0;
        if(token[tokenNameIndex].currentBuyPrice >= 0){
            while(whilePrice <= token[tokenNameIndex].currentBuyPrice){
                arrPriceBuy[counter] = whilePrice;
                uint volumeAtPrice = 0;
                uint offers_key = 0;

                offers_key = token[tokenNameIndex].buyBook[whilePrice].offers_key;
                while(offers_key <= token[tokenNameIndex].buyBook[whilePrice].offers_length){
                    volumeAtPrice += token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].amount;
                    offers_key++;
                }
                arrVolumeBuy[counter] = volumeAtPrice;
                //next whilePrice
                if(whilePrice == token[tokenNameIndex].buyBook[whilePrice].higherPrice){
                    break;
                }else{
                    whilePrice = token[tokenNameIndex].buyBook[whilePrice].higherPrice;
                }
                counter++;
            }
        }
        return(arrPriceBuy, arrVolumeBuy);
    }
    //Ask Orders
    function getSellOrderBook(string memory symbolName) public returns(uint[] memory, uint[] memory){
        uint8 tokenNameIndex = getSymbolIndex(symbolName);
        uint[] memory arrPriceSell = new uint[](token[tokenNameIndex].amountSellPrices);
        uint[] memory arrVolumeSell = new uint[](token[tokenNameIndex].amountSellPrices);

        uint sellWhilePrice = token[tokenNameIndex].currentSellPrice;
        uint sellCounter = 0;

        if(token[tokenNameIndex].currentSellPrice> 0){
            while(sellWhilePrice <= token[tokenNameIndex].highestSellPrice){
                arrPriceSell[sellCounter] = sellWhilePrice;
                uint sellVolumeAtPrice = 0;
                uint sell_offers_key = 0;

                sell_offers_key = token[tokenNameIndex].sellBook[sellWhilePrice].offers_key;
                while(sell_offers_key <= token[tokenNameIndex].sellBook[sellWhilePrice].offers_length){
                    sellVolumeAtPrice += token[tokenNameIndex].sellBook[sellWhilePrice].offers[sell_offers_key].amount;
                    sell_offers_key++;
                }
                arrVolumeSell[sellCounter] = sellVolumeAtPrice;
                //next whilePrice
                if(token[tokenNameIndex].sellBook[sellWhilePrice].higherPrice == 0){
                    break;
                }else{
                    sellWhilePrice = token[tokenNameIndex].sellBook[sellWhilePrice].higherPrice;
                }
                sellCounter++;
            }
        }
        return(arrPriceSell, arrVolumeSell);
    }
    //New Bid Order
    function buyToken(string memory symbolName, uint priceInWei, uint amount) public{
        uint8 tokenNameIndex = getSymbolIndex(symbolName);
        uint total_amount_ether_necessary = 0;


        if(token[tokenNameIndex].amountSellPrices == 0 || token[tokenNameIndex].currentSellPrice > priceInWei){
        //if we have enough ether,  we can buy that;
        total_amount_ether_necessary = amount * priceInWei;

        //overflowCheck
        require(total_amount_ether_necessary >= amount, 'invalid option');
        require(total_amount_ether_necessary >= priceInWei, 'invalid option');
        require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary, 'invalid option');
        require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary >= 0, 'invalid option');
        require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary <= balanceEthForAddress[msg.sender], 'invalid option');

        //first deduct the amount of ether from our balance
        balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;

        // limit order: we don't havee enough offers to fulfill the amount


        //add the order to the orderBook
        addBuyOffer(tokenNameIndex, priceInWei, amount, msg.sender);
        // and emit the event.
        emit LimitBuyOrderCreated(tokenNameIndex, amount, priceInWei, token[tokenNameIndex].buyBook[priceInWei].offers_length);
        }
        else{
            // market order: current sell price is smaller or equal to buy price!
            //1st: find the "cheapest sell price" that is lower than the buy amount  [buy: 60@5000] [sell: 500@4000]
            //2. buy up the volume for 4500
            //3. buy up the volume for 5000
            // if still something remaining -> buyToken

            // buy up the volume
            // add ether to seller, add symbolName to buyer until offers_key <= offers_length

            uint total_amount_ether_available = 0;
            uint whilePrice = token[tokenNameIndex].currentSellPrice;
            uint amountNecessary = amount;
            uint offers_key;
            while(whilePrice >= priceInWei && amountNecessary > 0){
                //we start with the lowest sell price
                offers_key = token[tokenNameIndex].sellBook[whilePrice].offers_key;
                while(offers_key <= token[tokenNameIndex].sellBook[whilePrice].offers_length && amountNecessary > 0){
                    //and the first order (FIFO)
                    uint volumenAtPriceFromAddress = token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].amount;



                    //The choices from here:
                    //1. one person offers not enough volume to fulfill the market order - we use it up completely and move on to the next persson who offers the symbolName
                    //2. else: we make use of parts of what a person is offering - lower his amount,fulfill out order.

                    if(volumenAtPriceFromAddress <= amountNecessary){
                        total_amount_ether_available = volumenAtPriceFromAddress * whilePrice;

                        require(balanceEthForAddress[msg.sender] >= total_amount_ether_available, 'invalid option');
                        require(balanceEthForAddress[msg.sender] - total_amount_ether_available <= balanceEthForAddress[msg.sender], 'invalid option');
                        //first deduct the amount of ether from our balance
                        balanceEthForAddress[msg.sender] -= total_amount_ether_available;

                        //this guy offers less or equal the volume that we ask for so we use it up completely.
                        tokenBalForAddress[token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].who][tokenNameIndex] += volumenAtPriceFromAddress;
                        token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].amount = 0;
                        balanceEthForAddress[token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].who] += total_amount_ether_available;
                        token[tokenNameIndex].sellBook[whilePrice].offers_key++;

                        emit SellOrderFulfilled(tokenNameIndex, volumenAtPriceFromAddress, whilePrice, offers_key);

                        amountNecessary -= volumenAtPriceFromAddress;
                    }else{
                        require(token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].amount > amountNecessary, 'invalid option');

                        total_amount_ether_necessary = amountNecessary * whilePrice;
                        require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender], 'invalid option');


                        //first deduct the amout of ether from our balance
                        balanceEthForAddress[msg.sender] += total_amount_ether_necessary;

                        require(tokenBalForAddress[msg.sender][tokenNameIndex] + volumenAtPriceFromAddress >= tokenBalForAddress[msg.sender][tokenNameIndex],'invalid option');
                        require(balanceEthForAddress[token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].who] + total_amount_ether_necessary >= balanceEthForAddress[token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].who], 'invalid option');

                        //overflow check
                        //this guy offers less or equal the volume that we ask forr, so we use it up completely.

                        token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].amount -= amountNecessary;
                        balanceEthForAddress[token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].who] += total_amount_ether_available;
                        tokenBalForAddress[msg.sender][tokenNameIndex] += amountNecessary;

                        amountNecessary = 0;
                        //we have fulfilled our order
                        emit SellOrderFulfilled(tokenNameIndex, amountNecessary, whilePrice, offers_key);
                    }

                    if(offers_key == token[tokenNameIndex].sellBook[whilePrice].offers_length && token[tokenNameIndex].sellBook[whilePrice].offers[offers_key].amount == 0){
                        token[tokenNameIndex].amountSellPrices--;
                        //we have one price offer less here....
                        // next whilePrice
                        if(whilePrice == token[tokenNameIndex].sellBook[whilePrice].higherPrice || token[tokenNameIndex].buyBook[whilePrice].higherPrice == 0){
                            token[tokenNameIndex].currentSellPrice = 0;
                        }else{
                            token[tokenNameIndex].currentSellPrice = token[tokenNameIndex].sellBook[whilePrice].higherPrice;
                            token[tokenNameIndex].sellBook[token[tokenNameIndex].buyBook[whilePrice].higherPrice].lowerPrice = 0;
                        }
                    }
                    offers_key++;
                }
                // we set the currentSellPrice again, since when the volume is used up for a lowest price the current Sell Price is there...
                whilePrice = token[tokenNameIndex].currentSellPrice;
            }
            if(amountNecessary > 0){
                buyToken(symbolName, priceInWei, amountNecessary);
                //add a limit order!!!
            }
        }

    }
    function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
        token[tokenIndex].buyBook[priceInWei].offers_length++;
        token[tokenIndex].buyBook[priceInWei].offers[token[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount,who);
        
        if(token[tokenIndex].buyBook[priceInWei].offers_length == 1){
            token[tokenIndex].buyBook[priceInWei].offers_key = 1;
        // we have a new buy order -- increase the counter, so we can set the getOrderBook array later
        token[tokenIndex].amountBuyPrices++;
        
        
        //lowerPrice and higherPrice have to be set
        uint currentBuyPrice = token[tokenIndex].currentBuyPrice;
        
        uint lowestBuyPrice = token[tokenIndex].lowestBuyPrice;
            if(lowestBuyPrice == 0 || lowestBuyPrice > priceInWei){
                if(currentBuyPrice == 0){
                    //there is no buy order yet, we insert the first one...
                token[tokenIndex].currentBuyPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                }else{
                //or the lowest one
                token[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = lowestBuyPrice;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
            }
                token[tokenIndex].lowestBuyPrice = priceInWei;
            }else if ( currentBuyPrice < priceInWei ){
            //the offer to buy is th highest, we don't need to find the right spot
                token[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = currentBuyPrice;
            }else{
                // we are somewhere in the middle, we need to find the right spot first..
                uint buyPrice = token[tokenIndex].currentBuyPrice;
                bool weFoundIt = false;
                while(buyPrice > 0 && !weFoundIt){
                  if(buyPrice < priceInWei && token[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei){
                      // set the new order-book entry higher/lowerPrice first right
                      token[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
                      token[tokenIndex].buyBook[priceInWei].higherPrice = token[tokenIndex].buyBook[buyPrice].higherPrice;
               
                    //set the higherPrice'd order-book entries lowrePrrice to the current Price
                    token[tokenIndex].buyBook[token[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;
                    
                    //set the higherPrice'd order-book entries lowrePrrice to the current Price
                    token[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;
                    
                    //set we found it.
                    weFoundIt = true;
                  }  
                  buyPrice = token[tokenIndex].buyBook[buyPrice].lowerPrice;
                }
            }
            
        }
        
    }
    //New Ask Order
    function sellToken(string memory symbolName, uint priceInWei, uint amount) public{
        uint8 tokenNameIndex = getSymbolIndex(symbolName);
        uint total_amount_ether_necessary = 0;
        uint total_amount_ether_available = 0;

        //if we have enough ether, we can buy that;
        total_amount_ether_necessary = amount * priceInWei;

        //overflow check
        require(total_amount_ether_necessary >= amount, "invalid entry");
        require(total_amount_ether_necessary >= priceInWei, "invalid entry");
        require(tokenBalForAddress[msg.sender][tokenNameIndex] >= amount, "invalid entry");
        require(tokenBalForAddress[msg.sender][tokenNameIndex] - amount >= 0, "invalid entry");
        require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender], "invalid entry");

        //actually subtract the amount of tokens to change it then
        tokenBalForAddress[msg.sender][tokenNameIndex] -= amount;

        if(token[tokenNameIndex].amountBuyPrices == 0 || token[tokenNameIndex].currentBuyPrice < priceInWei){
            //limit order: we don't have enough offers to fulfill the amount

            //add the order to the orderBook
            addSellOffer(tokenNameIndex, priceInWei, amount, msg.sender);
            // and emit the event.
            emit LimitSellOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, token[tokenNameIndex].sellBook[priceInWei].offers_length);
        }else{
            //market order: current buy prrice is bigger or equal to sell price!

            //1st: find the "higheest buuy price" that is higher than the sell amount [buy: 60@5000] [sell: 500@4000]
            //2. sell up the volume for 5000
            //3. sell up the volume for 4500
            // if still something remaining -> sellToken limit order

            // sell up the volume
            // add ether to seller, add symbolName to buyer until offers_key <= offers_length


            uint whilePrice = token[tokenNameIndex].currentBuyPrice;
            uint amountNecessary = amount;
            uint offers_key;
            while(whilePrice >= priceInWei && amountNecessary > 0){
                //we start with the highest buy price
                offers_key = token[tokenNameIndex].buyBook[whilePrice].offers_key;
                while(offers_key <= token[tokenNameIndex].buyBook[whilePrice].offers_length && amountNecessary > 0){
                    //and the first order (FIFO)
                    uint volumenAtPriceFromAddress = token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].amount;



                    //The choices from here:
                    //1. one person offers not enough volume to fulfill the market order - we use it up completely and move oon to the next persson who offers the symbolName
                    //2. elsee: we make use of parts of what a person is offering - lower his amoount, fulfill out order.

                    if(volumenAtPriceFromAddress <= amountNecessary){
                        total_amount_ether_available = volumenAtPriceFromAddress * whilePrice;

                         //overflow check
                        require(tokenBalForAddress[msg.sender][tokenNameIndex] - volumenAtPriceFromAddress >= 0, "invalid entry");
                        // require(tokenBalanceForAddress[token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].who][tokenNameIndex] + volumenAtPriceFromAddress >= tokenBalanceForAddress[token[tokenNameIndex]]);
                        require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender], "invalid entry");

                        //this guy offers less or equal the volume that we ask for so we use it up completely.
                        tokenBalForAddress[token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].who][tokenNameIndex] += volumenAtPriceFromAddress;
                        token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].amount = 0;
                        balanceEthForAddress[msg.sender] += total_amount_ether_available;
                        token[tokenNameIndex].buyBook[whilePrice].offers_key++;
                        emit SellOrderFulfilled(tokenNameIndex, volumenAtPriceFromAddress, whilePrice, offers_key);

                        amountNecessary -= volumenAtPriceFromAddress;
                    }else{
                        require(volumenAtPriceFromAddress - amountNecessary > 0, "invalid entry");
                        total_amount_ether_necessary = amountNecessary * whilePrice;

                        //take care of the outstanding amount

                        //overflow check
                        require(tokenBalForAddress[msg.sender][tokenNameIndex] >= amountNecessary,"invalid entry");
                        // require(tokenBalanceForAddress[token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].who][tokenNameIndex] + amountNecessary >= tokenBalanceForAddress[token[tokenNameIndex]]);
                        require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender], "invalid entry");


                        //this guy offers more than we ask for. We reduce his stack, add the eth to us and the symbollName to him.
                        token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].amount -= amountNecessary;
                        balanceEthForAddress[msg.sender] += total_amount_ether_necessary;
                        tokenBalForAddress[token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].who][tokenNameIndex] += amountNecessary;

                        emit SellOrderFulfilled(tokenNameIndex, amountNecessary, whilePrice, offers_key);

                        amountNecessary = 0;
                        //we have fulfilled our order;
                    }
                    //if it was the lastt offer for that price, we hav eto set thee current Buy Price now lower. Additionally we have one offer less...
                    if(offers_key == token[tokenNameIndex].buyBook[whilePrice].offers_length && token[tokenNameIndex].buyBook[whilePrice].offers[offers_key].amount ==0){
                       token[tokenNameIndex].amountBuyPrices--;
                       //we have one price offer less here....
                       //next whilePrice
                       if(whilePrice == token[tokenNameIndex].buyBook[whilePrice].lowerPrice || token[tokenNameIndex].buyBook[whilePrice].lowerPrice == 0){
                        // we havee reached the last price
                       }else{
                           token[tokenNameIndex].currentBuyPrice = token[tokenNameIndex].buyBook[whilePrice].lowerPrice;
                           token[tokenNameIndex].buyBook[token[tokenNameIndex].buyBook[whilePrice].lowerPrice].higherPrice = token[tokenNameIndex].currentBuyPrice;
                       }
                    }
                    offers_key++;
                }
            }

        }
    }
    function addSellOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal{
        token[tokenIndex].buyBook[priceInWei].offers_length++;
        token[tokenIndex].buyBook[priceInWei].offers[token[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount,who);

        if(token[tokenIndex].buyBook[priceInWei].offers_length == 1){
            token[tokenIndex].buyBook[priceInWei].offers_key = 1;
        // we have a new buy order -- increase the counter, so we can set the getOrderBook array later
        token[tokenIndex].amountBuyPrices++;


        //lowerPrice and higherPrice have to be set
        uint currentBuyPrice = token[tokenIndex].currentBuyPrice;

        uint lowestBuyPrice = token[tokenIndex].lowestBuyPrice;
            if(lowestBuyPrice == 0 || lowestBuyPrice > priceInWei){
                if(currentBuyPrice == 0){
                    //there is no buy order yet, we insert the first one...
                token[tokenIndex].currentBuyPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                }else{
                //or the lowest one
                token[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = lowestBuyPrice;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
            }
                token[tokenIndex].lowestBuyPrice = priceInWei;
            }else if ( currentBuyPrice < priceInWei ){
            //the offer to buy is th highest, we don't need to find the right spot
                token[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = priceInWei;
                token[tokenIndex].buyBook[priceInWei].lowerPrice = currentBuyPrice;
            }else{
                // we are somewhere in the middle, we need to find the right spot first..
                uint buyPrice = token[tokenIndex].currentBuyPrice;
                bool weFoundIt = false;
                while(buyPrice > 0 && !weFoundIt){
                  if(buyPrice < priceInWei && token[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei){
                      // set the new order-book entry higher/lowerPrice first right
                      token[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
                      token[tokenIndex].buyBook[priceInWei].higherPrice = token[tokenIndex].buyBook[buyPrice].higherPrice;

                    //set the higherPrice'd order-book entries lowrePrrice to the current Price
                    token[tokenIndex].buyBook[token[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;

                    //set the higherPrice'd order-book entries lowrePrrice to the current Price
                    token[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;

                    //set we found it.
                    weFoundIt = true;
                  }
                  buyPrice = token[tokenIndex].buyBook[buyPrice].lowerPrice;
                }
            }
        }
    }
    //Cancel Limit Order
    function cancelOrder(string memory symbolName, bool isSellOrder, uint priceInWei, uint offerkey) public{
        symbolNameIndex = getSymbolIndex(symbolName);
        if(isSellOrder){
            require(token[symbolNameIndex].sellBook[priceInWei].offers[offerkey].who == msg.sender, "invalid entry");
            uint tokenAmount = token[symbolNameIndex].sellBook[priceInWei].offers[offerkey].amount;
            require(tokenBalForAddress[msg.sender][symbolNameIndex] + tokenAmount >= tokenBalForAddress[msg.sender][symbolNameIndex], "invalid entry");

            tokenBalForAddress[msg.sender][symbolNameIndex] += tokenAmount;
            token[symbolNameIndex].sellBook[priceInWei].offers[offerkey].amount = 0;
            emit SellOrderCanceled(symbolNameIndex, priceInWei, offerkey);
        }else{
            require(token[symbolNameIndex].sellBook[priceInWei].offers[offerkey].who == msg.sender, "invalid entry");
            uint etherToRefund = token[symbolNameIndex].buyBook[priceInWei].offers[offerkey].amount * priceInWei;
            require(balanceEthForAddress[msg.sender] + etherToRefund >= balanceEthForAddress[msg.sender], "invalid entry");

            balanceEthForAddress[msg.sender] += etherToRefund;
            token[symbolNameIndex].buyBook[priceInWei].offers[offerkey].amount = 0;
            emit BuyOrderCanceled(symbolNameIndex, priceInWei, offerkey);
        }
    }
}
