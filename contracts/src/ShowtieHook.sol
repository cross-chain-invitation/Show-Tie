// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ISPHook} from "@ethsign/sign-protocol-evm/src/interfaces/ISPHook.sol";
import {Showtie} from "./Showtie.sol";
import { Attestation } from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
import { ISP } from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";

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

    function _verifyECDSA(bytes32 messageHash, bytes memory signature, address expectedSigner)
        internal
        pure
        returns (bool)
    {
        address recoveredSigner = verifySignature(messageHash, signature);
        return recoveredSigner == expectedSigner;
    }
}

// @dev This contract implements the actual schema hook.
contract ShowtieHook is ISPHook, Verifier {
    error UnsupportedOperation();

    function didReceiveAttestation(
        address, // attester
        uint64, // schemaId
        uint64 attestationId, //attestationId
        bytes calldata // extraData
    ) external payable {
      Attestation memory attestation = ISP(msg.sender).getAttestation(attestationId);
        (
            address invitee,
            address inviter,
            uint256 dappsId,
            bytes memory inviteeSignature,
            bytes memory captchaSignature,
            address captchaSigner,
            ,
        ) = abi.decode(attestation.data, (address, address, uint256, bytes, bytes, address, uint256, uint256));

        bytes32 messageHash = keccak256(abi.encodePacked(inviter, dappsId));
        _verifyECDSA(messageHash, inviteeSignature, invitee);

        bytes32 capthcaMessageHash = keccak256(abi.encodePacked(invitee, dappsId));
        _verifyECDSA(capthcaMessageHash, captchaSignature, captchaSigner);
    }

    function didReceiveAttestation(
        address, // attester
        uint64, // schemaId
        uint64, // attestationId
        IERC20, // resolverFeeERC20Token
        uint256, // resolverFeeERC20Amount
        bytes calldata // extraData
    ) external pure {
        revert UnsupportedOperation();
    }

    function didReceiveRevocation(
        address, // attester
        uint64, // schemaId
        uint64, // attestationId
        bytes calldata // extraData
    ) external payable {
        revert UnsupportedOperation();
    }

    function didReceiveRevocation(
        address, // attester
        uint64, // schemaId
        uint64, // attestationId
        IERC20, // resolverFeeERC20Token
        uint256, // resolverFeeERC20Amount
        bytes calldata // extraData
    ) external pure {
        revert UnsupportedOperation();
    }
}
