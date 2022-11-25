// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

//Get funds from users
//Withdraw funds
//Set minimum value in USD

contract FundMe {

    uint256 public minimumUsd = 50;

    function fund() public payable {
        // Able to set a minimum USD$ amount
        require(msg.value >= minimumUsd, "you did not send enough ETH");

    }

    function getPrice() public {
        //ABI
        //Address 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e

    }

    function getConversionRate() public {

    }

    // function withdraw() {

    // }
}
