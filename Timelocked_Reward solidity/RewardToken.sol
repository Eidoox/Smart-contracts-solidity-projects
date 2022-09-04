// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Reward is ERC20{
    constructor () ERC20 ("Reward token" , "Reward"){
        _mint(msg.sender, 3000 * 10**18);
    }
}
