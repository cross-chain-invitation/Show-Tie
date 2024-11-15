// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract InvitationManager {
    address public signProtocolContract;
    address public ccipContract;

    mapping(bytes32 => uint64) public crossChainAttestationIds;

    event InvitationCreated();
    event InvitationSentToCCIP();
    event CrossChainAttestationCreated();
    event InviteeAttestationCreated();

    constructor(address _signProtocolContract, address _ccipContract) {
        signProtocolContract = _signProtocolContract;
        ccipContract = _ccipContract;
    }

    function createInvitation() external {
        emit InvitationCreated();
    }


    function _sendInvitationToCCIP() external {
    }

    function receiveCrossChainMessage(
    ) external {
        // TODO : Verify the inviter's signature

        // TODO : Create a cross-chain attestation

        // TODO : Store the cross-chain attestation ID

        // TODO : Emit event
    }


    function approveInvitation(bytes memory captchaSignature) external {
        
        // TODO : Verify the CAPTCHA signature

        // TODO : Create Invitee Attestation

        // TODO : Emit Event

    }

    function getCrossChainAttestationId(address inviterAddress, uint256 dappsId) external view returns (uint64) {
        bytes32 key = keccak256(abi.encodePacked(inviterAddress, dappsId));
        return crossChainAttestationIds[key];
    }


    // Use for verify inviter's signature is actually signed by inviter
    function verifySignature(
        address signer,
        bytes memory signature
    ) internal view returns (bool) {
    }

    function verifyCaptchaSignature(
        address invitee,
        bytes memory signature
    ) internal pure returns (bool) {
    }

}
