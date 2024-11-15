// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Script, console} from "forge-std/Script.sol";
// import {Showtie} from "../src/Showtie.sol";

// contract CounterScript is Script {
//     Showtie public showtie;

//     function setUp() public {}

//     function run() public {
//         vm.startBroadcast();

//         showtie = new Showtie();

        

//         vm.stopBroadcast();
//     }
// }


// // Example: Deploy Contract A on Chain 1 and Contract B on Chain 2
// contract DeployScripts is Script {
//     function run() public {
//         vm.startBroadcast();

//         // Chain 1 Deployment (e.g., Ethereum)
//         address contractA = address(new ContractA());

//         // Switch RPC for Chain 2 Deployment (e.g., Polygon)
//         vm.rpc("polygon", "https://polygon-rpc.com");
//         address contractB = address(new ContractB());

//         vm.stopBroadcast();
//     }
// }
