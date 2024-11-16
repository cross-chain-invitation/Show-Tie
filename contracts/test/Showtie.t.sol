// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol"; // FoundryのTestライブラリ
import "solady/utils/ECDSA.sol";
import "../src/Showtie.sol";
import "forge-std/console.sol";

contract testShowtie is Test {
    MockSignProtocol mockSignProtocol;

    using ECDSA for bytes32;

    Showtie public showtie;
    Showtie public showtie2;

    address sourceRouter = address(2);
    address link = address(3);
    uint64 chainSelector = 10344971235874465080; //base

    address inviter = 0x917Db2634713b7CDD80F18455D7c540633698D10;

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
        vm.prank(0x842DC0443Ac0cc6423bB7D64cF54d4e4b6a244De);
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

    function testApproveInvitation() public {
        vm.prank(0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352);
        showtie.approveInvitation(
            1,
            inviter,
            hex"f670b3393d39ddcc23ca6ba580869d82e8d9de3069255f5bc85c237bb5caad554577610df9cad724eec94e8ed893dc5a98895dc1c41d5b46736cc3c1e56aac4f1b",
            hex"6e431900e0c08b4c2cf29f9eb21dbd07a852e7f012c2cd5beff7610df1006ece051ab4e11155f3c5692c54a3c891444819ddc8c264dcbc0363e2f79809aae7651b"
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
