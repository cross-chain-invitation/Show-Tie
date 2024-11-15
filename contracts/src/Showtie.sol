// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
// import { ISP } from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";
// import { Attestation } from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
// import { DataLocation } from "@ethsign/sign-protocol-evm/src/models/DataLocation.sol";
import "solady/utils/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "forge-std/console.sol";

contract Showtie is OwnerIsCreator, CCIPReceiver {
    using ECDSA for bytes32;

    address public signProtocolContract;
    address public ccipContract;
    address private captchaSigner;

    IRouterClient private s_router;

    string private s_lastReceivedText; // Store the last received text.

    LinkTokenInterface private s_linkToken;

    mapping(bytes32 => uint64) public crossChainAttestationIds;
    mapping(bytes => bool) public isSignatureUsed;
    mapping(address => bool) public isInvited;

    event InvitationCreated(bytes32 ccipMessageId);
    event CrossChainAttestationCreated();
    event InviteeAttestationCreated();
    // The chain selector of the destination chain.
    // The address of the receiver on the destination chain.
    // the token address used to pay CCIP fees.
    // The Dapps ID
    // The address of the inviter,
    // The fees paid for sending the CCIP message.
    event CCIPMessageSent(
        // The unique ID of the CCIP message.
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        address feeToken,
        uint256 dappsId,
        address inviterAddress,
        uint256 fees
    );
    event MessageReceived(
        // The unique ID of the message.
        // The chain selector of the source chain.
        // The address of the sender from the source chain.
        // The text that was received.
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        string text
    );

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

    constructor(
        address _signProtocolContract,
        address _router,
        address _link
    ) CCIPReceiver(_router) {
        signProtocolContract = _signProtocolContract;
        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
        captchaSigner = msg.sender;
    }

    function createInvitation(
        uint64 destinationChainSelector,
        address targetContract,
        uint256 dappsId,
        bytes calldata signature
    ) external {
        bytes32 ccipMessageId = _sendInvitationViaCCIP(
            destinationChainSelector,
            targetContract,
            dappsId,
            signature
        );
        emit InvitationCreated(ccipMessageId);
    }

    function _sendInvitationViaCCIP(
        uint64 destinationChainSelector,
        address receiver,
        uint256 dappsId,
        bytes calldata signature
    ) internal returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(dappsId, msg.sender, signature),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV2({
                    gasLimit: 200_000,
                    allowOutOfOrderExecution: true
                })
            ),
            feeToken: address(s_linkToken)
        });
        uint256 fees = s_router.getFee(
            destinationChainSelector,
            evm2AnyMessage
        );
        if (fees > s_linkToken.balanceOf(address(this))) {
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }

        s_linkToken.approve(address(s_router), fees);
        messageId = s_router.ccipSend(destinationChainSelector, evm2AnyMessage);
        emit CCIPMessageSent(
            messageId,
            destinationChainSelector,
            receiver,
            address(s_linkToken),
            dappsId,
            msg.sender,
            fees
        );
        return messageId;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        s_lastReceivedText = abi.decode(any2EvmMessage.data, (string)); // abi-decoding of the sent text
        (uint256 dappsId, address sender, bytes memory signature) = abi.decode(
            any2EvmMessage.data,
            (uint256, address, bytes)
        );

        // require(
        //     verifyECDSASignature(
        //         sender, keccak256(abi.encodePacked(dappsId, any2EvmMessage.sourceChainSelector)), signature
        //     )
        // );
        // TODO : Cross-Chain Attesttationを作成

        // TODO :  Cross-Chain Attestationの保存

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            abi.decode(any2EvmMessage.data, (string))
        );
    }

    function approveInvitation(
        uint256 dappsId,
        address invitor,
        bytes memory captchaSignature
    ) external {
        require(isInvited[msg.sender] == false, "Already invited");
        require(
            isSignatureUsed[captchaSignature] == false,
            "Signature already used"
        );
        // require(
        //     verifyECDSASignature(captchaSigner, keccak256(abi.encodePacked(dappsId, msg.sender)), captchaSignature)
        // );

        // TODO : Create Invitee Attestation
        // TODO : Emit Event
    }

    function getCrossChainAttestationId(
        address inviterAddress,
        uint256 dappsId
    ) external view returns (uint64) {
        bytes32 key = keccak256(abi.encodePacked(inviterAddress, dappsId));
        return crossChainAttestationIds[key];
    }

    // Use it only for test
    function getLastReceivedText() external view returns (string memory) {
        return s_lastReceivedText;
    }

    // function verifyECDSASignature(
    //     address signerAddress,
    //     bytes32 messageHash,
    //     bytes memory signature
    // ) public view returns (bool) {
    //     console.log("Signer Address: ", signerAddress);
    //     bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
    //     address recovered = ECDSA.recover(
    //         MessageHashUtils.toEthSignedMessageHash(messageHash),
    //         signature
    //     );
    //     console.logAddress(recovered);
    //     return recovered == signerAddress;
    // }

    function verifySignature(address signer, bytes32 messageHash, bytes memory signature)
        public
        view
        returns (bool)
    {
        // Ethereum標準の署名ハッシュを作成
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        // 署名からアドレスを復元
        address recoveredSigner = recoverV2(ethSignedMessageHash, signature);

        // 署名者のアドレスと比較
        return recoveredSigner == signer;
    }

    function verifyV2(
        address signerAddress,
        string calldata message,
        bytes calldata signature
    ) public view {
        bytes32 signedMessageHash = keccak256(abi.encode(message))
            .toEthSignedMessageHash();
        require(
            signedMessageHash.recover(signature) == signerAddress,
            "signature not valid v2"
        );
    }

    function recoverV2(bytes32 hash, bytes memory sig) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solhint-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }
}
