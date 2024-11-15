// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Showtie.sol"; // 実際のコントラクトファイルを指定

contract InvitationTest is Test {
    Showtie showtie;
    address captchaSigner;
    address invitor;
    address invitee;
    uint256 dappsId = 12345;

    function setUp() public {
        // テスト用のコントラクトをデプロイ
        captchaSigner = makeAddr("captchaSigner");
        invitor = makeAddr("invitor");
        invitee = makeAddr("invitee");

        invitationContract = new Showtie(captchaSigner);
    }

    function testApproveInvitation() public {
        // 署名を生成
        bytes32 messageHash = keccak256(abi.encodePacked(dappsId, invitee));
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(captchaSigner)), ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        // `approveInvitation` を呼び出す
        vm.prank(invitee); // invitee のコンテキストで実行
        invitationContract.approveInvitation(dappsId, invitor, signature);

        // 結果を検証
        assertTrue(invitationContract.isInvited(invitee), "Invitation approval failed");
        assertTrue(invitationContract.isSignatureUsed(signature), "Signature not marked as used");
    }

    function testApproveInvitationFailsForDuplicate() public {
        // 署名を生成
        bytes32 messageHash = keccak256(abi.encodePacked(dappsId, invitee));
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(captchaSigner)), ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        // 初回呼び出し
        vm.prank(invitee);
        invitationContract.approveInvitation(dappsId, invitor, signature);

        // 再度呼び出しは失敗する
        vm.prank(invitee);
        vm.expectRevert("Already invited");
        invitationContract.approveInvitation(dappsId, invitor, signature);
    }

    function testApproveInvitationFailsForInvalidSignature() public {
        // 無効な署名を生成
        bytes32 invalidMessageHash = keccak256(abi.encodePacked(dappsId + 1, invitee)); // 異なる内容でハッシュ化
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(invalidMessageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(captchaSigner)), ethSignedMessageHash);
        bytes memory invalidSignature = abi.encodePacked(r, s, v);

        // 呼び出しは失敗する
        vm.prank(invitee);
        vm.expectRevert("Invalid signature!");
        invitationContract.approveInvitation(dappsId, invitor, invalidSignature);
    }

    function testGetCrossChainAttestationId() public {
        // crossChainAttestationIdを設定するための署名
        bytes32 key = keccak256(abi.encodePacked(invitor, dappsId));
        uint64 attestationId = 99999; // テスト用の値
        invitationContract.setCrossChainAttestationId(key, attestationId); // 内部関数があれば置き換え

        // 取得結果を検証
        uint64 result = invitationContract.getCrossChainAttestationId(invitor, dappsId);
        assertEq(result, attestationId, "CrossChainAttestationId mismatch");
    }
}
