// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol"; // FoundryのTestライブラリ
import "solady/utils/ECDSA.sol";
import "../src/Showtie.sol";
import "forge-std/console.sol";

contract VerifyECDSASignatureTest is Test {
    using ECDSA for bytes32;
    Showtie public showtie;
    address private signer;
    uint256 privateKey =
        0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        showtie = new Showtie(address(1), address(2), address(3), 1, 2, 3, 4);
        signer = vm.addr(privateKey); // 秘密鍵に対応するアドレスを生成
    }

    function testVerifySignature() public view {
        // テストメッセージを定義
        string memory message = "Hello, ECDSA!";
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        // Ethereum標準のメッセージハッシュを作成
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        // メッセージを署名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        // 署名を検証
        bool isValid = showtie.verifySignature(signer, messageHash, signature);
        assertTrue(isValid, "Signature verification should succeed for valid signature");
        // 不正な署名を検証
        address fakeSigner = address(0xDEADBEEF);
        bool isInvalid = showtie.verifySignature(fakeSigner, messageHash, signature);
        assertFalse(isInvalid, "Signature verification should fail for invalid signer");
        // メッセージを改ざんして検証
        string memory fakeMessage = "Fake message";
        bytes32 fakeMessageHash = keccak256(abi.encodePacked(fakeMessage));
        bool isInvalidMessage = showtie.verifySignature(signer, fakeMessageHash, signature);
        assertFalse(isInvalidMessage, "Signature verification should fail for invalid message");
    }
}