// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Verifier {
    // メッセージハッシュと署名から署名者のアドレスを回復する関数
    function verifySignature(
        bytes32 messageHash,
        bytes memory signature
    ) public pure returns (address) {
        // メッセージハッシュをEthereumの署名形式に変換
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        // 署名からr, s, vを分解
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        
        // 署名から署名者のアドレスを回復
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    // 署名の検証を行う関数
    function verify(
        uint256 dappsId,
        uint64 chainSelectorId,
        bytes memory signature,
        address expectedSigner
    ) public pure returns (bool) {
        // メッセージのハッシュを作成
        bytes32 messageHash = keccak256(
            abi.encodePacked(dappsId, chainSelectorId)
        );
        
        // 署名から署名者のアドレスを回復
        address recoveredSigner = verifySignature(messageHash, signature);
        
        // 期待する署名者と一致するか確認
        return recoveredSigner == expectedSigner;
    }
} 