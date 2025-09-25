//1. deploy mocks when we are on a local anvil chain
//2. keep track of contract address across different chains

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; 
import {MockV3Aggregator} from "mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE=2000E8;
   
   struct NetworkConfig{
       address priceFeed; //ETH/USD priceFeed address
   }

   constructor(){
    if(block.chainid==11155111){
        activeNetworkConfig = getSepoliaEthConfig(); 
    } else if(block.chainid==1){
        activeNetworkConfig = getMainnetEthConfig();
    }else {
        activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
   }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        //pricefeed address (vrf addres, gas price, ..etc)
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig; //getting existing address
    }

     function getMainnetEthConfig() public pure returns (NetworkConfig memory){
        //pricefeed address (vrf addres, gas price, ..etc)
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig; //getting existing address
    }

    function getOrCreateAnvilEthConfig() public returns( NetworkConfig memory){
       if(activeNetworkConfig.priceFeed != address(0)){   //if mock already deployed no need to create again
         return activeNetworkConfig; 
       }
       
       //pricefeed address
       vm.startBroadcast();
       MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
       vm.stopBroadcast();
       NetworkConfig memory anvilConfig = NetworkConfig({
           priceFeed: address(mockPriceFeed) //takes deployed address of mockv3aggregator not the whole contrac
       });
       return anvilConfig;
    }
}