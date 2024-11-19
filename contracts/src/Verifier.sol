// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Verifier {
    function verifySignature(bytes32 messageHash, bytes memory signature) public pure returns (address) {
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function verifyECDSA(bytes32 messageHash, bytes memory signature, address expectedSigner)
        external
        pure
        returns (bool)
    {
        address recoveredSigner = verifySignature(messageHash, signature);
        return recoveredSigner == expectedSigner;
    }
}
