// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAI is ERC20{
    constructor () ERC20 ("Test DAI Token" , "DAI"){
    }
    function GetSomeTestTokens (uint256 _amount) public {
        _mint(msg.sender, _amount);

    }
}