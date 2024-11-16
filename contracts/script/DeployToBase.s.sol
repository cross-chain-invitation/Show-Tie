// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Showtie.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract DeployToBase is Script {
    LinkTokenInterface private s_linkToken = LinkTokenInterface(0xE4aB69C077896252FAFBD49EFD26B5D171A32410);

    function run() public {
        vm.startBroadcast();

        Showtie showtie = new Showtie(
            0x4e4af2a21ebf62850fD99Eb6253E1eFBb56098cD, //Sign Protocol
            0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93, //CCIP router
            0xE4aB69C077896252FAFBD49EFD26B5D171A32410, //LINK token
            10344971235874465080, //CCIP Chain selector
            0x41e, //InviterSchema
            0x423, //Crosschain Schema
            0x425 //Invitee Schema
        );

        console.log("Showtie deployed at:", address(showtie));
        s_linkToken.transfer(address(showtie), 1000000000000000000);

        vm.stopBroadcast();
    }
}

contract callCCIP is Script {
    function run() public {
        vm.startBroadcast();
        address showtieAddress = 0x53D1D42c154934FF03Ed26579BB88C9A4834F698;
        Showtie showtie = Showtie(showtieAddress);

        uint64 destinationChainSelector = 16015286601757825753; //
        address targetContract = 0x900E61f9CF646453aa208e423372B87FA0C53846;

        // 関数を実行
        showtie.createInvitation(destinationChainSelector, targetContract, 1, bytes(""));

        // デプロイの終了
        vm.stopBroadcast();
    }
}
