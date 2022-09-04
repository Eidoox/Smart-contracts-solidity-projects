// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Eidoox is ERC20{
    constructor () ERC20 ("Eidoox token" , "Eid"){
        _mint(msg.sender, 10000 * 10**18);
    }
}
