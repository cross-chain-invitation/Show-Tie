// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {ISP} from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";
import {Attestation} from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
import {DataLocation} from "@ethsign/sign-protocol-evm/src/models/DataLocation.sol";
import "solady/utils/ECDSA.sol";
import "forge-std/console.sol";

contract Showtie is OwnerIsCreator, CCIPReceiver {
    using ECDSA for bytes32;

    address private captchaSigner;
    uint64 public chainSelector;
    LinkTokenInterface private s_linkToken;
    IRouterClient private s_router;
    ISP public spInstance;

    uint64 public inviterSchemaId;
    uint64 public inviteeSchemaId;
    uint64 public crosschainSchemaId;

    mapping(bytes32 => uint64) public crossChainAttestationIds;
    mapping(bytes => bool) public isSignatureUsed;
    mapping(address => bool) public isInvited;
    mapping(uint256 => uint64) public dappsIdToChainSelector;

    event InvitationCreated(bytes32 ccipMessageId, uint64 attestationId);
    event CrossChainAttestationCreated();
    event InviteeAttestationCreated();

    event CCIPMessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        address feeToken,
        uint256 dappsId,
        address inviterAddress,
        uint256 fees
    );

    event MessageReceived(bytes32 indexed messageId, uint64 indexed sourceChainSelector, address sender, string text);

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

    constructor(
        address _signProtocolContract,
        address _router,
        address _link,
        uint64 _chainSelector,
        uint64 _inviterSchemaId,
        uint64 _inviteeSchemaId,
        uint64 _crosschainSchemaId
    ) CCIPReceiver(_router) {
        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
        captchaSigner = msg.sender;
        chainSelector = _chainSelector;
        spInstance = ISP(_signProtocolContract);
        inviterSchemaId = _inviterSchemaId;
        inviteeSchemaId = _inviteeSchemaId;
        crosschainSchemaId = _crosschainSchemaId;
    }

    function createInvitation(
        uint64 destinationChainSelector,
        address targetContract,
        uint256 dappsId,
        bytes calldata signature
    ) external {
        bytes[] memory recipients = new bytes[](1);
        recipients[0] = abi.encode(msg.sender);
        Attestation memory a = Attestation({
            schemaId: inviterSchemaId,
            linkedAttestationId: 0,
            attestTimestamp: 0,
            revokeTimestamp: 0,
            attester: address(this),
            validUntil: 0,
            dataLocation: DataLocation.ONCHAIN,
            revoked: true,
            recipients: recipients,
            data: abi.encode(msg.sender, signature, dappsId, uint256(chainSelector), uint256(destinationChainSelector))
        });
        uint64 attestationId = spInstance.attest(a, "", "", "");
        bytes32 ccipMessageId =
            _sendInvitationViaCCIP(destinationChainSelector, targetContract, dappsId, signature, attestationId);
        emit InvitationCreated(ccipMessageId, attestationId);
    }

    function _sendInvitationViaCCIP(
        uint64 destinationChainSelector,
        address receiver,
        uint256 dappsId,
        bytes memory signature,
        uint64 attestationId
    ) internal returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(dappsId, msg.sender, signature, attestationId),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            // extraArgs: Client._argsToBytes(Client.EVMExtraArgsV2({gasLimit: 200_000, allowOutOfOrderExecution: true})),
            extraArgs: "",
            feeToken: address(s_linkToken)
        });
        uint256 fees = s_router.getFee(destinationChainSelector, evm2AnyMessage);
        if (fees > s_linkToken.balanceOf(address(this))) {
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }

        s_linkToken.approve(address(s_router), fees);
        messageId = s_router.ccipSend(destinationChainSelector, evm2AnyMessage);
        emit CCIPMessageSent(
            messageId, destinationChainSelector, receiver, address(s_linkToken), dappsId, msg.sender, fees
        );
        return messageId;
    }

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
        internal
        pure
        returns (bool)
    {
        address recoveredSigner = verifySignature(messageHash, signature);
        return recoveredSigner == expectedSigner;
    }

    function getCrossChainAttestationId(address inviterAddress, uint256 dappsId) internal view returns (uint64) {
        bytes32 key = keccak256(abi.encodePacked(inviterAddress, dappsId));
        return crossChainAttestationIds[key];
    }

    function _createCrossChainAttestation(
        uint256 dappsId,
        address inviter,
        bytes memory signature,
        uint64 inviterAttestationId,
        uint64 sourceChainSelector
    ) internal returns (uint64) {
        //For Production
        bytes32 messageHash = keccak256(abi.encodePacked(dappsId, sourceChainSelector));

        //For test CCIP
        // uint64 baseChainSelector = 10344971235874465080;
        // bytes32 messageHash = keccak256(abi.encodePacked(dappsId, baseChainSelector));

        require(verifyECDSA(messageHash, signature, inviter));

        bytes[] memory recipients = new bytes[](1);
        recipients[0] = abi.encode(inviter);
        Attestation memory a = Attestation({
            schemaId: crosschainSchemaId,
            linkedAttestationId: 0,
            attestTimestamp: 0,
            revokeTimestamp: 0,
            attester: address(this),
            validUntil: 0,
            dataLocation: DataLocation.ONCHAIN,
            revoked: false,
            recipients: recipients,
            data: abi.encode(
                inviter, uint256(inviterAttestationId), dappsId, uint256(sourceChainSelector), uint256(chainSelector)
            )
        });
        uint64 crossChainAttestationId = spInstance.attest(a, "", "", "");
        bytes32 key = keccak256(abi.encodePacked(inviter, dappsId));
        crossChainAttestationIds[key] = crossChainAttestationId;
        return crossChainAttestationId;
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        (uint256 dappsId, address inviter, bytes memory signature, uint64 inviterAttestationId) =
            abi.decode(any2EvmMessage.data, (uint256, address, bytes, uint64));
        uint64 sourceChainSelector = any2EvmMessage.sourceChainSelector;

        _createCrossChainAttestation(dappsId, inviter, signature, inviterAttestationId, sourceChainSelector);
    }

    function mochCcipReceive(
        uint256 dappsId,
        address inviter,
        bytes memory signature,
        uint64 inviterAttestationId,
        uint64 sourceChainSelector
    ) public {
        _createCrossChainAttestation(dappsId, inviter, signature, inviterAttestationId, sourceChainSelector);
    }

    function approveInvitation(
        uint256 dappsId,
        address inviter,
        bytes memory inviteeSignature,
        bytes memory captchaSignature
    ) external returns (uint64) {
        require(isInvited[msg.sender] == false, "Already invited");
        require(isSignatureUsed[captchaSignature] == false, "Signature already used");

        //For testing admin
        // address admin = 0x842DC0443Ac0cc6423bB7D64cF54d4e4b6a244De;

        bytes32 hashedMessage = keccak256(abi.encodePacked(msg.sender, dappsId));
        console.logBytes32(hashedMessage);
        require(verifyECDSA(hashedMessage, captchaSignature, captchaSigner));

        bytes32 messageHash = keccak256(abi.encodePacked(inviter, dappsId));
        require(verifyECDSA(messageHash, inviteeSignature, msg.sender));

        uint64 crossChainAttestationId = getCrossChainAttestationId(inviter, dappsId);
        uint64 sourceChainSelector = dappsIdToChainSelector[dappsId];

        bytes[] memory recipients = new bytes[](2);
        recipients[0] = abi.encode(inviter);
        recipients[1] = abi.encode(msg.sender);
        Attestation memory a = Attestation({
            schemaId: inviteeSchemaId,
            linkedAttestationId: crossChainAttestationId,
            attestTimestamp: 0,
            revokeTimestamp: 0,
            attester: address(this),
            validUntil: 0,
            dataLocation: DataLocation.ONCHAIN,
            revoked: false,
            recipients: recipients,
            data: abi.encode(
                msg.sender,
                inviter,
                dappsId,
                inviteeSignature,
                captchaSignature,
                captchaSigner,
                uint256(sourceChainSelector),
                uint256(chainSelector)
            )
        });
        uint64 inviteeAttestationId = spInstance.attest(a, "", "", "");

        isInvited[msg.sender] = true;
        isSignatureUsed[captchaSignature] = true;

        return inviteeAttestationId;
    }

    // -------------------------------------- Set Functions --------------------------------------
    function setSignProtocolContract(address _signProtocolContract) external onlyOwner {
        spInstance = ISP(_signProtocolContract);
    }

    function setCCIPRouter(address _router) external onlyOwner {
        s_router = IRouterClient(_router);
    }

    function setLINKToken(address _link) external onlyOwner {
        s_linkToken = LinkTokenInterface(_link);
    }

    function setCaptchaSigner(address _captchaSigner) external onlyOwner {
        captchaSigner = _captchaSigner;
    }

    function setInviterSchemaId(uint64 _inviterSchemaId) external onlyOwner {
        inviterSchemaId = _inviterSchemaId;
    }

    function setCroschainSchemaId(uint64 _crosschainSchemaId) external onlyOwner {
        crosschainSchemaId = _crosschainSchemaId;
    }

    function setInviteeSchemaId(uint64 _inviteeSchemaId) external onlyOwner {
        inviteeSchemaId = _inviteeSchemaId;
    }
}
