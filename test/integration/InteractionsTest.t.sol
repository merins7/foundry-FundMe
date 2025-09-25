//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {

    FundMe fundMe;
    address USER= makeAddr("user");   // we can put constant since compiling time constant not to be cared
    uint256 constant SEND_VALUE=0.1 ether;
    uint256 constant STARTING_BALANCE=10 ether;
    //uint256 constant GAS_PRICE=1;

    function setUp() external{
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public{
       // FundFundMe fundFundMe = new FundFundMe();
        //vm.deal(address(fundFundMe),STARTING_BALANCE); //fundFundMe contract calls fund function not USER directly
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
       // fundFundMe.fundFundMe(address(fundMe));// this is why, seperate fundFundMe function created so as to add own address
     

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}