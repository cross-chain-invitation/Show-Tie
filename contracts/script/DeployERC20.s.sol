// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/ShowtieERC20.sol";

contract DeployERC20 is Script {
    function run() public {
        vm.startBroadcast();

        ShowtieERC20 showtieERC20 = new ShowtieERC20();

        console.log("Showtie deployed at:", address(showtieERC20));

        vm.stopBroadcast();
    }
}
