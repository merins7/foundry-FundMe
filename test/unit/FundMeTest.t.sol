//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    uint256 number=1;
    FundMe fundMe;
    address USER= makeAddr("user");   // we can put constant since compiling time constant not to be cared
    uint256 constant SEND_VALUE=0.1 ether;
    uint256 constant STARTING_BALANCE=10 ether;
    //uint256 constant GAS_PRICE=1;

    function setUp() external{
        number=2;
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public view{
         assertEq(number,2);
         console.log("number is",number);
         console.log("hello");
         assertEq(fundMe.MINIMUM_USD(),5e18);
         console.log("MINIMUM_USD is",fundMe.MINIMUM_USD()); 
    }
    function testOwnerIsMsgSender() public view{
        console.log("owner is",fundMe.getOwner()); //fundMe.i_owner() before making i_owner private
        console.log("msg.sender is",msg.sender);
        assertEq(fundMe.getOwner(),msg.sender);//before address(this) //fundMe.i_owner() before making i_owner private
    }
    function testPriceFeedVersionIsAccurate() public view{
        if(block.chainid == 11155111){
            assertEq(fundMe.getVersion(),4);
        } else if(block.chainid == 1){
            assertEq(fundMe.getVersion(),6);
        }
    
    }

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert(); //// expect next line to revert , if next line fails then test passed
        fundMe.fund();//send 0 ETH, as value not specified
        //fundMe.fund{value:1e16}(); //0.01 ETH
    }
    
    function testFundedUpdatesFundedDataStructure() public{
       vm.prank(USER);
       fundMe.fund{value: SEND_VALUE}(); 

       uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
       assertEq(amountFunded,SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
         //funding from non-owner

        vm.prank(USER); //as each prank applies to only next call
        vm.expectRevert(); // expect next line to revert , if next line fails then test passed
        fundMe.withdraw(); //withdraw from non-owner , line fail
    }

    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
       // uint256 gasStart = gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log("Gas Used:",gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(endingOwnerBalance,startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for(uint160 i=startingIndex; i<numberOfFunders; i++){
            //vm.prank + vm.deal = hoax
            //addres(i)
            hoax(address(i),SEND_VALUE); //STARTING_BALANCE should come
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance==0);
        assert(fundMe.getOwner().balance == startingFundMeBalance + startingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for(uint160 i=startingIndex; i<numberOfFunders; i++){
            //vm.prank + vm.deal = hoax
            //addres(i)
            hoax(address(i),SEND_VALUE); //STARTING_BALANCE should come
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance==0);
        assert(fundMe.getOwner().balance == startingFundMeBalance + startingOwnerBalance);
    }
    

}