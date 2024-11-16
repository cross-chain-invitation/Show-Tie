// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Verifier.sol";
import "forge-std/console.sol";
import "solady/utils/ECDSA.sol";

contract VerifierTest is Test {
    using ECDSA for bytes32;

    Verifier public verifier;
    address private signer;
    uint256 private signerPrivateKey;

    function setUp() public {
        // テスト用の秘密鍵を設定
        signerPrivateKey = 0x1234567890123456789012345678901234567890123456789012345678901234;
        signer = vm.addr(signerPrivateKey);
        verifier = new Verifier();
    }

    function testVerifySignature() public view {
        // テストメッセージを定義
        string memory message = "Hello, ECDSA!";
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        // Ethereum標準のメッセージハッシュを作成
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        // メッセージを署名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        // 署名を検証
        bool isValid = verifier.verifyECDSA(messageHash, signature, signer);
        assertTrue(isValid, "Signature verification should succeed for valid signature");
        // 不正な署名を検証
        address fakeSigner = address(0xDEADBEEF);
        bool isInvalid = verifier.verifyECDSA(messageHash, signature, fakeSigner);
        assertFalse(isInvalid, "Signature verification should fail for invalid signer");
        // メッセージを改ざんして検証
        string memory fakeMessage = "Fake message";
        bytes32 fakeMessageHash = keccak256(abi.encodePacked(fakeMessage));
        bool isInvalidMessage = verifier.verifyECDSA(fakeMessageHash, signature, signer);
        assertFalse(isInvalidMessage, "Signature verification should fail for invalid message");
    }

    function testVerifyInvalidSigner() public view {
        uint256 dappsId = 1;
        uint64 destinationChainSelector = 10344971235874465080;

        bytes memory signature =
            hex"fc8f432f1cc9cfe6e6e0c0fcae24e6a88095cddce7207168318eb7e2e7a512355b4ccb2a6dee336951c2ede6e827f4255eeddfa54339d5c03fe4a2031301747f1b";
        address correctSigner = 0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352;
        bytes32 messageHash = keccak256(abi.encodePacked(dappsId, destinationChainSelector));

        bool isValid = verifier.verifyECDSA(messageHash, signature, correctSigner);

        assertTrue(isValid, "Signature verification should succeed with correct signer");
    }

    function testVerifyInvalidSigner2() public view {
        uint256 dappsId = 1;
        address inviter = 0x917Db2634713b7CDD80F18455D7c540633698D10;
        address invitee = 0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352;

        bytes memory signature =
            hex"6e431900e0c08b4c2cf29f9eb21dbd07a852e7f012c2cd5beff7610df1006ece051ab4e11155f3c5692c54a3c891444819ddc8c264dcbc0363e2f79809aae7651b";
        bytes32 messageHash = keccak256(abi.encodePacked(inviter, dappsId));

        bool isValid = verifier.verifyECDSA(messageHash, signature, invitee);

        assertTrue(isValid, "Signature verification should succeed with correct signer");
    }
}
