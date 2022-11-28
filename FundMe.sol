// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./PriceConverter.sol";
//Get funds from users
//Withdraw funds
//Set minimum value in USD

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMU_USD = 1 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    function fund() public payable {
        // Able to set a minimum USD$ amount
        require(msg.value.getConversionRate() >= MINIMU_USD, "you did not send enough ETH");
        //msg.value will have 18 decimals
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;

    }


    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funderAddress = funders[funderIndex];
            addressToAmountFunded[funderAddress] = 0;
        }
        //reset the array
        funders = new address[](0);

        //withdraw the funds
        (bool callSuccess, /*bytes memory dataReturned*/) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
