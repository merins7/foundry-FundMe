//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe fundMe = FundMe(payable(mostRecentlyDeployed));

        //FundMe(payable(mostRecentlyDeployed)).fund{value:SEND_VALUE}();
        /**
         * Calls the fund function directly on a temporary casted FundMe instance.
         *     No local variable for FundMe.
         */
        vm.startBroadcast();
        fundMe.fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // vm.startBroadcast(); /* if broadcasting was placed in fundFundMe function then then broadcast is send each time
        // when we call for multiple function calls, here broadcast is sent only once even if we call multiple times fundFundMe function */
        fundFundMe(mostRecentlyDeployed);
        // vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        FundMe fundMe = FundMe(payable(mostRecentlyDeployed));
        vm.startBroadcast();
        fundMe.withdraw();
        vm.stopBroadcast();
        console.log("Withdrew from FundMe contract");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        //vm.stopBroadcast();
    }
}
