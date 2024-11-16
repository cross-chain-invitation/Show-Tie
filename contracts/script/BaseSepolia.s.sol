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
            0x483, //Invitee Schema
            0x423 //Crosschain Schema
        );

        console.log("Showtie deployed at:", address(showtie));
        s_linkToken.transfer(address(showtie), 1000000000000000000);

        vm.stopBroadcast();
    }
}

contract callReceive is Script {
    uint256 dappsId = 1;
    address inviter = 0xf78f634e7D8322aB0Fe0C061B9629Dc5EBEc43c3;
    bytes inviterSignature = hex"e90648da7514257352f849f9e70485fb3f528ed7523b85194f11df574ed86ab3286b4cfa96d1794b1bfe785ae79c684fa64e19b24338fe521f4418cbb4e661531c";
    uint64 inviterAttestationId = 1;
    uint64 sourceChainSelector = 16015286601757825753;  //Sepolia Chain Selector

    function run() public {
        vm.startBroadcast();

        address baseShowtieAddress = 0x445216B90703FDAfD64A5037817C9F5E8377e79E;
        Showtie showtie = Showtie(baseShowtieAddress);

        showtie.mochCcipReceive(dappsId, inviter, inviterSignature, inviterAttestationId, sourceChainSelector);

        vm.stopBroadcast();
    }
}

contract callApprove is Script {
    uint256 dappsId = 1;
    address inviter = 0xf78f634e7D8322aB0Fe0C061B9629Dc5EBEc43c3;
    bytes inviteeSignature = hex"7c1d25f5fe85b7a411a76e8ec7b71166e6f884a12f18da11b607f2b9244e24ac0d534fcd1cee42ad0a0444637a78318e14c62eeb918062d3a5e557336981de111c";
    bytes captchaSignature = hex"f309639603b90252aad92da2b12af74b23b2ce3416572b2ee7894908c323e098075a7c6d2c26465a25e18920317247ad845b1c9ac475ae98b5963d632b7935f41b";

    function run() public {
        vm.startBroadcast();

        address baseShowtieAddress = 0xABF8250bE844d6E88153b688A22D3030a88e42a1;
        Showtie showtie = Showtie(baseShowtieAddress);

        showtie.approveInvitation(dappsId, inviter, inviteeSignature, captchaSignature);

        vm.stopBroadcast();
    }

}
