// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Showtie.sol"; // Showtieコントラクトのパス
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract DeployToSepolia is Script {
    LinkTokenInterface private s_linkToken = LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    address immutable TARGET_CONTRACT = 0xABF8250bE844d6E88153b688A22D3030a88e42a1; //Base Sepolia

    function run() public {
        vm.startBroadcast();
        // Deploy Contract
        Showtie showtie = new Showtie(
            0x878c92FD89d8E0B93Dc0a3c907A2adc7577e39c5,
            0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            16015286601757825753,
            0x2ed,  //Inviter
            0x304,  //Invitee
            0x303  // Cross-Chain
        );
        console.log("Sepolia Showtie deployed at:", address(showtie));

        //Send LINK Token
        uint256 amount = 1000000000000000000; // 1 LINK
        s_linkToken.transfer(address(showtie), amount);

        vm.stopBroadcast();
    }
}

contract callCCIP is Script {
    address immutable TARGET_CONTRACT = 0xABF8250bE844d6E88153b688A22D3030a88e42a1; //Base Sepolia

    function run() public {
        vm.startBroadcast();
        address showtieAddress = 0xc6a3C5ce873481F0EB6Bb2b172cDD6e27e8aCff1; //Sepolia Contract
        Showtie showtie = Showtie(showtieAddress);

        uint64 destinationChainSelector = 10344971235874465080; //Base Chain Selector
        uint256 dappsId = 1;
        bytes memory signature =
            hex"5cb69f5561b34a4244c1a91ade3d838effed20d3c03cb140dab91ff5db6faf7c7f0babe3275172b8db9adabc61780d7b9a6763271ac0ae25b30e000c93363b2e1b";
        showtie.createInvitation(destinationChainSelector, TARGET_CONTRACT, dappsId, signature);

        vm.stopBroadcast();
    }
}

contract callReceive is Script {
    uint256 dappsId = 1;
    address inviter = 0xf78f634e7D8322aB0Fe0C061B9629Dc5EBEc43c3;
    bytes inviterSignature = hex"5cb69f5561b34a4244c1a91ade3d838effed20d3c03cb140dab91ff5db6faf7c7f0babe3275172b8db9adabc61780d7b9a6763271ac0ae25b30e000c93363b2e1b";
    uint64 inviterAttestationId = 1;
    uint64 sourceChainSelector = 10344971235874465080;  //Base Chain Selector

    function run() public {
        vm.startBroadcast();

        address baseShowtieAddress = 0xc6a3C5ce873481F0EB6Bb2b172cDD6e27e8aCff1;
        Showtie showtie = Showtie(baseShowtieAddress);

        showtie.mochCcipReceive(dappsId, inviter, inviterSignature, inviterAttestationId, sourceChainSelector);

        vm.stopBroadcast();
    }
}
