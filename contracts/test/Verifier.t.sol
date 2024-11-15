// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Verifier.sol";
import "forge-std/console.sol";

contract VerifierTest is Test {
    Verifier public verifier;
    address private signer;
    uint256 private signerPrivateKey;

    function setUp() public {
        // テスト用の秘密鍵を設定
        signerPrivateKey = 0x1234567890123456789012345678901234567890123456789012345678901234;
        signer = vm.addr(signerPrivateKey);
        verifier = new Verifier();
    }

    // function testVerifyValidSignature() public {
    //     // テストデータを準備
    //     uint256 dappsId = 1;
    //     uint64 destinationChainSelector = 10344971235874465080;
        
    //     // メッセージをハッシュ化
    //     bytes memory message = abi.encodePacked(dappsId, destinationChainSelector);
    //     bytes32 messageHash = keccak256(message);
        
    //     // Ethereum署名メッセージハッシュを作成
    //     bytes32 ethSignedMessageHash = keccak256(
    //         abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    //     );

    //     // 署名を生成
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
    //     bytes memory signature = abi.encodePacked(r, s, v);

    //     // 署名を検証
    //     bool isValid = verifier.verify(
    //         dappsId,
    //         destinationChainSelector,
    //         signature,
    //         signer
    //     );

    //     assertTrue(isValid, "Signature verification should succeed");
    // }

    function testVerifyInvalidSigner() public {
        uint256 dappsId = 1;
        uint64 destinationChainSelector = 10344971235874465080;
        
        bytes memory signature = hex"fc8f432f1cc9cfe6e6e0c0fcae24e6a88095cddce7207168318eb7e2e7a512355b4ccb2a6dee336951c2ede6e827f4255eeddfa54339d5c03fe4a2031301747f1b";
        address correctSigner = 0x9cE87dcbD55f8eD571EFF906584cB6A83B5c2352;

        bool isValid = verifier.verify(
            dappsId,
            destinationChainSelector,
            signature,
            correctSigner
        );

        assertTrue(isValid, "Signature verification should succeed with correct signer");
    }
} 