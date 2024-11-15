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

    function setup() public {
        showtie = new Showtie(address(1), address(0), address(0));
        signer = vm.addr(privateKey); // 秘密鍵に対応するアドレスを生成
    }

    // function testVerifyV1andV2() public view {
    //     string memory message = "attack at dawn";

    //     bytes32 msgHash = keccak256(abi.encode(message))
    //         .toEthSignedMessageHash();

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);

    //     bytes memory signature = abi.encodePacked(r, s, v);
    //     assertEq(signature.length, 65);

    //     console.logBytes(signature);
    //     showtie.verifyV2(vm.addr(privateKey), message, signature);
    // }

    // function testVerifyECDSASignatureV1() public view {
    //     // テストメッセージ
    //     string memory message = "Hello, Solady!";
    //     bytes32 messageHash = keccak256(abi.encodePacked(message));

    //     // Ethereum署名メッセージハッシュを計算
    //     bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

    //     // メッセージの署名を生成
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(
    //         privateKey,
    //         ethSignedMessageHash
    //     );
    //     bytes memory signature = abi.encodePacked(r, s, v);

    //     // 復元したアドレスを確認
    //     address recoveredSigner = ethSignedMessageHash.recover(signature);
    //     assertEq(
    //         recoveredSigner,
    //         signer,
    //         "Recovered signer does not match the expected signer"
    //     );

    //     // 署名の検証
    //     bool isValid = showtie.verifyECDSASignature(
    //         signer,
    //         messageHash,
    //         signature
    //     );
    //     assertTrue(isValid, "Signature verification failed");
    // }

    // function testVerifyECDSASignature() public view {
    //     address signerAddress = 0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352;
    //     uint256 dappsId = 1;
    //     uint64 destinationChainSelector = 10344971235874465080;
    //     bytes memory message = abi.encodePacked(
    //         dappsId,
    //         destinationChainSelector
    //     );
    //     console.logBytes(message);
    //     bytes32 messageHash = keccak256(message);
    //     console.logBytes32(messageHash);
    //     bytes
    //         memory signature = hex"01bd50efcc1d0c9bf6e446eed0a6c74a1293da87519d9d9fe86a021a36952c1f428492c2a745305cf72e4fc575322cad5be72547718805fec059df88c29ad7461c";
    //     bool isValid = showtie.verifyECDSASignature(
    //         signerAddress,
    //         messageHash,
    //         signature
    //     );
    //     assertEq(isValid, true);
    //     // bytes32 fakeMessageHash = keccak256(abi.encodePacked("Fake message"));
    //     // bool isInvalid = showtie._verifyECDSASignature(signerAddress, fakeMessageHash, signature);
    //     // assertFalse(isInvalid, "Signature verification passed for invalid message hash");
    // }

    function testVerifySignature() public {
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
