// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Showtie.sol"; // Showtieコントラクトのパス
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract DeployToSepolia is Script {
    LinkTokenInterface private s_linkToken = LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    address immutable TARGET_CONTRACT = 0x1952FE5d7460328B2C31511c05EdA78F39aB0A42; //Base Sepolia

    function run() public {
        vm.startBroadcast();
        // Deploy Contract
        Showtie showtie = new Showtie(
            0x878c92FD89d8E0B93Dc0a3c907A2adc7577e39c5,
            0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            16015286601757825753,
            0x2ed,
            0x0,
            0x0
        );
        console.log("Showtie deployed at:", address(showtie));

        //Send LINK Token
        uint256 amount = 1000000000000000000; // 1 LINK
        s_linkToken.transfer(address(showtie), amount);

        // Call create Invitation
        uint64 destinationChainSelector = 10344971235874465080; //Base Chain Selector
        uint256 dappsId = 1;
        bytes memory signature =
            hex"96bfd20f3db1f6e78bfec633ec3968c7ceffbf335968474a7103172ba565c30c4a46fa53f2016e5dd5674c0a9ca7e571f793d49fde637eb62e257fce344e32251b";
        showtie.createInvitation(destinationChainSelector, TARGET_CONTRACT, dappsId, signature);

        vm.stopBroadcast();
    }
}

contract callCCIP is Script {
    address immutable TARGET_CONTRACT = 0x1952FE5d7460328B2C31511c05EdA78F39aB0A42; //Base Sepolia

    function run() public {
        address showtieAddress = 0x53D1D42c154934FF03Ed26579BB88C9A4834F698; //Sepolia Contract
        Showtie showtie = Showtie(showtieAddress);
        vm.startBroadcast();

        uint64 destinationChainSelector = 10344971235874465080; //Base Chain Selector
        uint256 dappsId = 1;
        bytes memory signature =
            hex"96bfd20f3db1f6e78bfec633ec3968c7ceffbf335968474a7103172ba565c30c4a46fa53f2016e5dd5674c0a9ca7e571f793d49fde637eb62e257fce344e32251b";
        showtie.createInvitation(destinationChainSelector, TARGET_CONTRACT, dappsId, signature);

        vm.stopBroadcast();
    }
}
