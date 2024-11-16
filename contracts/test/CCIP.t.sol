// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {CCIPLocalSimulator, LinkToken} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {BasicMessageSender} from "./CCIP/BasicMessageSender.sol";
import {BasicMessageReceiver} from "./CCIP/BasicMessageReceiver.sol";
import "../src/Showtie.sol";
import {ISP} from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";
import {ISPHook} from "@ethsign/sign-protocol-evm/src/interfaces/ISPHook.sol";
import {Attestation} from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
import {DataLocation} from "@ethsign/sign-protocol-evm/src/models/DataLocation.sol";


contract Example06Test is Test {
    CCIPLocalSimulator public ccipLocalSimulator;
    Showtie public showtie;
    Showtie public showtie2;
    BasicMessageSender public sender;
    BasicMessageReceiver public receiver;

    address signProtocol = address(1);
    uint64 inviterSchemaId = 1;
    uint64 inviteeSchemaId = 2;
    uint64 crosschainSchemaId = 3;
    uint64 crosschainSchemaId2 = 4;

    address mockISP = address(0x123456);

    uint64 public destinationChainSelector;

    MockSignProtocol mockSignProtocol;

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();
        mockSignProtocol = new MockSignProtocol();

        (
            uint64 chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            ,
            LinkToken link,
            ,

        ) = ccipLocalSimulator.configuration();

        showtie = new Showtie(address(mockSignProtocol), address(sourceRouter), address(link), chainSelector, inviterSchemaId, inviteeSchemaId, crosschainSchemaId);
        showtie2 = new Showtie(address(mockSignProtocol), address(sourceRouter), address(link), chainSelector, inviterSchemaId, inviteeSchemaId, crosschainSchemaId2);
        sender = new BasicMessageSender(address(sourceRouter), address(link));
        receiver = new BasicMessageReceiver(address(destinationRouter));

        destinationChainSelector = chainSelector;

    }

    function test_sendAndReceiveCrossChainMessagePayFeesInLink() external {
        ccipLocalSimulator.requestLinkFromFaucet(address(showtie), 5 ether);

        showtie.createInvitation(
            destinationChainSelector,
            address(showtie2),
            1,
            hex"fc8f432f1cc9cfe6e6e0c0fcae24e6a88095cddce7207168318eb7e2e7a512355b4ccb2a6dee336951c2ede6e827f4255eeddfa54339d5c03fe4a2031301747f1b"
        );

        // assertEq(latestMessageId, messageId);
        // assertEq(latestSourceChainSelector, destinationChainSelector);
        // assertEq(latestSender, address(sender));
        // assertEq(latestMessage, messageToSend);
    }
}

contract MockSignProtocol {
    function attest(
        Attestation calldata, 
        string calldata,
        bytes calldata,
        bytes calldata
    ) external pure returns (uint64) {
        return 42;
    }
}
