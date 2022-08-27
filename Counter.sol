// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint256 mycounter; 

    constructor(){
        mycounter = 0;
    }

    function IncreaseMyCounter () external  {
        mycounter++ ; 
    }

    function DecreaseMyCounter () external  {
        mycounter--;
    }
    function GetMyCounter() external view returns (uint256 _counter){
        return mycounter;
    }
}
