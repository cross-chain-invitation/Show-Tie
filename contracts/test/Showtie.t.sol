// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol"; // FoundryのTestライブラリ
import "solady/utils/ECDSA.sol";
import "../src/Showtie.sol";
import "forge-std/console.sol";

contract VerifyECDSASignatureTest is Test {
    MockSignProtocol mockSignProtocol;

    using ECDSA for bytes32;

    Showtie public showtie;
    Showtie public showtie2;

    address sourceRouter = address(2);
    address link = address(3);
    uint64 chainSelector = 10344971235874465080; //base

    address inviter = 0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352;

    address signProtocol = address(1);
    uint64 inviterSchemaId = 1;
    uint64 inviteeSchemaId = 2;
    uint64 crosschainSchemaId = 3;
    uint64 crosschainSchemaId2 = 4;

    address mockISP = address(0x123456);

    uint64 public destinationChainSelector;
    address private signer;
    uint256 privateKey = 0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        mockSignProtocol = new MockSignProtocol();
        showtie = new Showtie(
            address(mockSignProtocol),
            sourceRouter,
            link,
            chainSelector,
            inviterSchemaId,
            inviteeSchemaId,
            crosschainSchemaId
        );
    }

    function testVerification() public {
        vm.prank(0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352);
        showtie.approveInvitation(
            1,
            inviter,
            hex"bb72a383fc6b4b1099f67c7807640efa6f56d5a10876ce24d7ed3511a281a872061063f7a42d6fecae4bc936d61a601dcd750a71cdfc130244cbc920479ecac21c"
        );
    }
}

contract MockSignProtocol {
    function attest(Attestation calldata, string calldata, bytes calldata, bytes calldata)
        external
        pure
        returns (uint64)
    {
        return 42;
    }
}
