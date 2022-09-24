// SPDX-License-Identifier: MTI
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";




contract NFTMarketplace is ReentrancyGuard {
    uint256  marketitemscount;
    address payable  withdrawfeesaccount; //owner to withdraw fees
    uint256  marketfeespercentage;


    struct nftmarketitem{
        uint256 itemid;
        address nftcontractaddress;
        uint256 tokenid;
        address payable seller;
        uint256 price;
        bool issold;
        bool islisted;
    }
    mapping (uint256 => nftmarketitem) nftmarketitems;

    
    event sellnft(
        uint256 itemid,
        address indexed nftcontractaddress,
        uint256 tokenid,
        address indexed seller,
        uint256 price
    );
    event buyingnft(
        uint256 itemid,
        address indexed nftcontractaddress,
        uint256 tokenid,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );


    //Stake state variables 
    IERC20  rewardsToken; // Reward token (Reward)
    uint256 allowdeposit_time_endat;
    uint256 allowdeposit_duration = 1 minutes; 

    mapping (address => bool) isdeposited ;  
    mapping (address => bool) iscanceledstaking;  
    mapping (address => mapping (address => uint256)) stakednftstokens; // user address >  nftcontractaddress > tokenid


    uint256 takeprofit_time;
    uint256 takeprofit_duration = 1 minutes;  
    address [] stakers;


    modifier OnlyDeployer {
        require (withdrawfeesaccount == msg.sender , "Only contract deployer can call this function");
        _;
    }

    constructor (uint256 _feespercentage , address rewardtokenaddress) {
        marketfeespercentage = _feespercentage;
        withdrawfeesaccount = payable(msg.sender);
        //staking
        rewardsToken = IERC20 (rewardtokenaddress);
        allowdeposit_time_endat = block.timestamp + allowdeposit_duration;
    }

    // list function (sell nft) 
    function listnft (address nftcontractaddress, uint256 tokenid, uint256 price) external nonReentrant {
        require(price > 0 , "price should greater than 0");
        marketitemscount ++;
        require (nftmarketitems[marketitemscount].islisted == false , " item is already listed");
        nftmarketitems[marketitemscount] = nftmarketitem (
            marketitemscount,
            nftcontractaddress,
            tokenid,
            payable(msg.sender),
            price,
            false,
            true
        );
        IERC721(nftcontractaddress).transferFrom(msg.sender, address(this), tokenid);
        
        emit sellnft(
            marketitemscount,
            nftcontractaddress,
            tokenid,
            msg.sender,
            price
        );
    } 
    // Buy NFT function

    function buynft (uint256 marketitemid) external payable nonReentrant {
        require (marketitemid >0 && marketitemid<= marketitemscount , "invalid market item id");
        require (msg.sender != nftmarketitems[marketitemid].seller , "buyer can not be seller");
        uint256 nfttotalprice = totalpricewith_marketfees(marketitemid);
        nftmarketitem storage nftitem = nftmarketitems[marketitemid];
        require (msg.value == nfttotalprice , "Pay what seller requires");
        require (nftitem.issold == false, "this nft is already sold");
        nftitem.seller.transfer(nftitem.price);
        withdrawfeesaccount.transfer(nfttotalprice - nftitem.price);
        IERC721(nftitem.nftcontractaddress).transferFrom( address(this) ,msg.sender, nftitem.tokenid);

        nftitem.issold = true;
        nftitem.seller = payable(msg.sender);
        nftitem.islisted = false;

        emit buyingnft(
            marketitemid,
            nftitem.nftcontractaddress,
            nftitem.tokenid,
            nftitem.seller,
            msg.sender,
            nftitem.price
        );
    }

    //Function to apply market fees (1%)
    function totalpricewith_marketfees (uint256 marketitemid) public view returns (uint256) {
        uint256 totalprice= nftmarketitems[marketitemid].price ;
        uint256 totalpricewithfees = totalprice* (100+marketfeespercentage);
        return totalpricewithfees/100;
    }

    function getmarketdata ( uint256 marketitemid) public view returns (nftmarketitem memory){
        return nftmarketitems[marketitemid];
    }

    function gettotalcountitems () public view returns (uint256) {
        return marketitemscount;
    }


    // Staking Functions

    function startstaking () public OnlyDeployer {
        allowdeposit_time_endat = block.timestamp + allowdeposit_duration;
    }


    function stakeNFT (address nftcontractaddress, uint256 tokenid) public {
        require (block.timestamp <= allowdeposit_time_endat , "duration to deposit has been passed");
        IERC721(nftcontractaddress).transferFrom(msg.sender, address(this), tokenid);
        isdeposited[msg.sender] = true;
        takeprofit_time = allowdeposit_time_endat + takeprofit_duration;
        stakednftstokens[msg.sender][nftcontractaddress]=tokenid;
        stakers.push(msg.sender); 
    }

    function cancelstaking () public {
        require(isdeposited[msg.sender] == true , "You did not deposit NFTs");
        require(block.timestamp < takeprofit_time , "You could not not cancel locking, withdraw your nft with profits");
        iscanceledstaking[msg.sender] = true;
    }


    function claimrewards (address nftcontractaddress) public {
        require(isdeposited[msg.sender] == true , "You did not stake NFTs");
        require(iscanceledstaking[msg.sender] == false , "You have canceled the staking, you are able to withdraw without reward tokens");
        require(block.timestamp >= takeprofit_time , "wait until the time of taking profit comes");
        uint256 tokenid = stakednftstokens[msg.sender][nftcontractaddress]; 
        IERC721(nftcontractaddress).transferFrom(address(this), msg.sender, tokenid);
        rewardsToken.transfer(msg.sender, 100000000000000000000); // 1000 tokens reward 
        isdeposited[msg.sender] = false; 
    }

    function claimnftonly_withoutrewards (address nftcontractaddress) public{
        require(isdeposited[msg.sender] == true , "You did not deposit locked token");
        require(iscanceledstaking[msg.sender] == true , "To withdraw without reward, you have to cancel locking first");
        uint256 tokenid = stakednftstokens[msg.sender][nftcontractaddress]; 
        IERC721(nftcontractaddress).transferFrom(address(this), msg.sender, tokenid);
        isdeposited[msg.sender] = false;
    }
   
    
}
