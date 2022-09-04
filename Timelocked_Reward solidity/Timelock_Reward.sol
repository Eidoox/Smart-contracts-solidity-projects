// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract timelock_reward {

    address owner; 
    IERC20  lockedtoken; // Eidoox token (Original)
    IERC20  rewardsToken; // Reward token (Reward)

    uint256 allowdeposit_time_endat;
    uint256 allowdeposit_duration = 5 minutes; 

    mapping (address => bool) isdeposited ;  
    mapping (address => uint256) amount_lockedtokendeposited;  
    mapping (address => bool) iscanceledlocking;  

    uint256 takeprofit_time;
    uint256 takeprofit_duration = 5 minutes;  
    address [] depositers;


    constructor  (address _lockedtoken , address _rewardtoken){
        owner = msg.sender;
        lockedtoken = IERC20 (_lockedtoken);
        rewardsToken = IERC20 (_rewardtoken);
        allowdeposit_time_endat = block.timestamp + allowdeposit_duration;
    }

    modifier OnlyDeployer {
        require (owner == msg.sender , "Only contract deployer can call this function");
        _;
    }

    function startdepostingagain () public OnlyDeployer {
        allowdeposit_time_endat = block.timestamp + allowdeposit_duration;
    }

    function deposittokens (uint256 depositedlockedtoken_amount) public {
        require (block.timestamp <= allowdeposit_time_endat , "duration to deposit has been passed");
        require(lockedtoken.balanceOf(msg.sender) >= depositedlockedtoken_amount , "you do not have this amount of tokens (Insuffcient balance)");
        lockedtoken.transferFrom(msg.sender,address(this), depositedlockedtoken_amount);
        isdeposited[msg.sender] = true;
        amount_lockedtokendeposited[msg.sender] = depositedlockedtoken_amount;
        takeprofit_time = allowdeposit_time_endat + takeprofit_duration;
        depositers.push(msg.sender); 
    }

    function withdrawtokens_with_reward () public {
        require(isdeposited[msg.sender] == true , "You did not deposit locked token");
        require(iscanceledlocking[msg.sender] == false , "You have canceled the locking, you are able to withdraw tokens without rewards");
        require(block.timestamp >= takeprofit_time , "wait until the time of taking profit comes");
        uint256 rewardtoken_amount = amount_lockedtokendeposited[msg.sender] / 100 ;
        lockedtoken.transfer(msg.sender, amount_lockedtokendeposited[msg.sender]);
        rewardsToken.transfer(msg.sender, rewardtoken_amount);
        isdeposited[msg.sender] = false;
    }

     

    function cancellocking () public {
        require(isdeposited[msg.sender] == true , "You did not deposit locked token");
        require(block.timestamp < takeprofit_time , "You can not cancel locking, withdraw your fund with profits");
        iscanceledlocking[msg.sender] = true;
    }

    function withdrawtokens_without_reward () public{
        require(isdeposited[msg.sender] == true , "You did not deposit locked token");
        require(iscanceledlocking[msg.sender] == true , "To withdraw without reward, you have to cancel locking first");
        require(lockedtoken.balanceOf(address(this)) >= amount_lockedtokendeposited[msg.sender] , "Contract does not have your amount now, please try again later");
        lockedtoken.transfer(msg.sender, amount_lockedtokendeposited[msg.sender]);
        isdeposited[msg.sender] = false;
    }


    function getdespositers () public OnlyDeployer view returns (address [] memory ) {
        return depositers;
    }

  
}
