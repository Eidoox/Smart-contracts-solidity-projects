// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    constructor () ERC20 ("Test Warpped ETH Token" , "WETH"){
    }
    function GetSomeTestTokens (uint256 _amount) public {
        _mint(msg.sender, _amount);

    }
}