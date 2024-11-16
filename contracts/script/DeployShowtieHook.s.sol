// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/ShowtieHook.sol";

contract DeployShowtieHook is Script {
    function run() public {
        vm.startBroadcast();

        ShowtieHook showtieHook = new ShowtieHook();
        console.log("Showtie deployed at:", address(showtieHook));

        vm.stopBroadcast();
    }
}
