// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract Showtie is OwnerIsCreator {
    address public signProtocolContract;
    address public ccipContract;

    IRouterClient private s_router;

    LinkTokenInterface private s_linkToken;

    mapping(bytes32 => uint64) public crossChainAttestationIds;

    event InvitationCreated();
    event CrossChainAttestationCreated();
    event InviteeAttestationCreated();
    event CCIPMessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        string text, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

    constructor(address _signProtocolContract, address _router, address _link) {
        signProtocolContract = _signProtocolContract;
        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
    }

    function createInvitation(uint64 destinationChainSelector, address targetContract, string calldata text) external {
        _sendInvitationViaCCIP(destinationChainSelector, targetContract, text);
        emit InvitationCreated();
    }

    function _sendInvitationViaCCIP(
        uint64 destinationChainSelector,
        address receiver,
        string calldata text
    ) internal returns (bytes32 messageId) { 
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(text), 
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

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        s_linkToken.approve(address(s_router), fees);
        messageId = s_router.ccipSend(destinationChainSelector, evm2AnyMessage);

        emit CCIPMessageSent(
            messageId,
            destinationChainSelector,
            receiver,
            text,
            address(s_linkToken),
            fees
        );
        return messageId;
    }

    function receiveCrossChainMessage() external {
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

    function getCrossChainAttestationId(
        address inviterAddress,
        uint256 dappsId
    ) external view returns (uint64) {
        bytes32 key = keccak256(abi.encodePacked(inviterAddress, dappsId));
        return crossChainAttestationIds[key];
    }

    // Use for verify inviter's signature is actually signed by inviter
    function verifySignature(
        address signer,
        bytes memory signature
    ) internal view returns (bool) {}

    function verifyCaptchaSignature(
        address invitee,
        bytes memory signature
    ) internal pure returns (bool) {}
}
