// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.28;

// import "forge-std/Test.sol";
// import "../src/Showtie.sol";
// import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
// import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

// // Mock RouterClient
// contract MockRouterClient is IRouterClient {
//     uint256 public fee;
//     bytes32 public lastMessageId;
//     Client.EVM2AnyMessage public lastSentMessage;

//     mapping(uint64 => bool) public supportedChains;

//     function setFee(uint256 _fee) external {
//         fee = _fee;
//     }

//     function getFee(
//         uint64 /*destinationChainSelector*/,
//         Client.EVM2AnyMessage memory /*message*/
//     ) external view override returns (uint256) {
//         return fee;
//     }

//     function ccipSend(
//         uint64 /*destinationChainSelector*/,
//         Client.EVM2AnyMessage memory message
//     ) external payable override returns (bytes32) {
//         lastSentMessage = message;
//         lastMessageId = keccak256(
//             abi.encodePacked(block.timestamp, message.receiver, message.data)
//         );

//         // メッセージ受信をシミュレート
//         address receiverAddress = abi.decode(message.receiver, (address));
//         Client.Any2EVMMessage memory any2EvmMessage = Client.Any2EVMMessage({
//             messageId: lastMessageId,
//             sourceChainSelector: uint64(block.chainid),
//             sender: abi.encode(msg.sender),
//             data: message.data,
//             destTokenAmounts: new Client.EVMTokenAmount[](0)
//         });

//         // 受信コントラクトのccipReceiveを呼び出す
//         CCIPReceiver(receiverAddress).ccipReceive(any2EvmMessage);

//         return lastMessageId;
//     }

//     function isChainSupported(
//         uint64 destChainSelector
//     ) external view override returns (bool supported) {
//         return supportedChains[destChainSelector];
//     }
// }

// // Mock LinkToken
// contract MockLinkToken is LinkTokenInterface {
//     mapping(address => uint256) public balances;
//     mapping(address => mapping(address => uint256)) public allowances;

//     function balanceOf(
//         address owner
//     ) external view override returns (uint256 balance) {
//         return balances[owner];
//     }

//     function transfer(
//         address to,
//         uint256 value
//     ) external override returns (bool success) {
//         require(balances[msg.sender] >= value, "Not enough balance");
//         balances[msg.sender] -= value;
//         balances[to] += value;
//         return true;
//     }

//     function approve(
//         address spender,
//         uint256 value
//     ) external override returns (bool success) {
//         allowances[msg.sender][spender] = value;
//         return true;
//     }

//     function transferFrom(
//         address from,
//         address to,
//         uint256 value
//     ) external override returns (bool success) {
//         require(balances[from] >= value, "Not enough balance");
//         require(allowances[from][msg.sender] >= value, "Not enough allowance");
//         balances[from] -= value;
//         allowances[from][msg.sender] -= value;
//         balances[to] += value;
//         return true;
//     }

//     function allowance(
//         address owner,
//         address spender
//     ) external view override returns (uint256 remaining) {
//         return allowances[owner][spender];
//     }

//     function totalSupply() external view override returns (uint256 supply) {
//         return 0; // 実装簡略化のため
//     }

//     function name() external view override returns (string memory) {
//         return "Mock LINK";
//     }

//     function symbol() external view override returns (string memory) {
//         return "mLINK";
//     }

//     function decimals() external view override returns (uint8) {
//         return 18;
//     }

//     // テスト用のトークン発行関数
//     function mint(address to, uint256 amount) external {
//         balances[to] += amount;
//     }

//     // decreaseApproval の実装
//     function decreaseApproval(
//         address spender,
//         uint256 subtractedValue
//     ) external override returns (bool success) {
//         uint256 currentAllowance = allowances[msg.sender][spender];
//         if (subtractedValue >= currentAllowance) {
//             allowances[msg.sender][spender] = 0;
//         } else {
//             allowances[msg.sender][spender] -= subtractedValue;
//         }
//         return true;
//     }

//     // increaseApproval の実装
//     function increaseApproval(
//         address spender,
//         uint256 addedValue
//     ) external override {
//         allowances[msg.sender][spender] += addedValue;
//     }

//     // transferAndCall の実装
//     function transferAndCall(
//         address to,
//         uint256 value,
//         bytes calldata data
//     ) external override returns (bool success) {
//         return true;
//     }
// }

// // テストコントラクト
// contract ShowtieTest is Test {
//     Showtie public showtie;
//     MockRouterClient public mockRouter;
//     MockLinkToken public mockLinkToken;
//     address public signProtocolContract = address(0x1234567890abcdef);

//     function setUp() public {
//         mockRouter = new MockRouterClient();
//         mockLinkToken = new MockLinkToken();
//         showtie = new Showtie(
//             signProtocolContract,
//             address(mockRouter),
//             address(mockLinkToken)
//         );
//     }

//     function testCreateInvitation() public {
//         // ShowtieコントラクトにLINKトークンを供給
//         uint256 initialLinkBalance = 1000 * 10 ** 18;
//         mockLinkToken.mint(address(showtie), initialLinkBalance);

//         // モックRouterでの手数料設定
//         uint256 mockFee = 10 * 10 ** 18; // 10 LINKトークン
//         mockRouter.setFee(mockFee);

//         // テストデータ
//         uint64 destinationChainSelector = 12345; // ダミーのチェーンセレクタ
//         address targetContract = address(showtie); // テストのため同じコントラクトを使用
//         string memory text = "Hello, CCIP!";

//         // createInvitationを呼び出し
//         vm.prank(address(0x1)); // 呼び出し元をシミュレート
//         showtie.createInvitation(
//             destinationChainSelector,
//             targetContract,
//             text
//         );

//         // LINKトークンの残高確認
//         uint256 remainingLinkBalance = mockLinkToken.balanceOf(
//             address(showtie)
//         );
//         assertEq(
//             remainingLinkBalance,
//             initialLinkBalance - mockFee,
//             "Incorrect LINK balance after fee deduction"
//         );

//         // メッセージが正しく送信されたか確認
//         // assertEq(
//         //     mockRouter.lastSentMessage.receiver,
//         //     abi.encode(targetContract),
//         //     "Incorrect receiver"
//         // );
//         // assertEq(
//         //     abi.decode(mockRouter.lastSentMessage.data, (string)),
//         //     text,
//         //     "Incorrect message data"
//         // );

//         // メッセージが正しく受信・処理されたか確認
//         string memory lastReceivedText = showtie.getLastReceivedText();
//         assertEq(
//             lastReceivedText,
//             text,
//             "Received text does not match sent text"
//         );

//         // イベントの確認
//         // vm.recordLogsを使用してイベントをキャプチャ
//         vm.recordLogs();

//         // 再度createInvitationを呼び出してログを記録
//         vm.prank(address(0x2));
//         showtie.createInvitation(
//             destinationChainSelector,
//             targetContract,
//             text
//         );

//         // 記録されたログを取得
//         Vm.Log[] memory logs = vm.getRecordedLogs();

//         // InvitationCreatedイベントの存在を確認
//         bool invitationCreatedEventFound = false;
//         bytes32 invitationCreatedEventSignature = keccak256(
//             "InvitationCreated()"
//         );
//         for (uint i = 0; i < logs.length; i++) {
//             if (logs[i].topics[0] == invitationCreatedEventSignature) {
//                 invitationCreatedEventFound = true;
//                 break;
//             }
//         }
//         assertTrue(
//             invitationCreatedEventFound,
//             "InvitationCreated event not found"
//         );

//         // CCIPMessageSentイベントの存在を確認
//         bool ccipMessageSentEventFound = false;
//         bytes32 ccipMessageSentEventSignature = keccak256(
//             "CCIPMessageSent(bytes32,uint64,address,string,address,uint256)"
//         );
//         for (uint i = 0; i < logs.length; i++) {
//             if (logs[i].topics[0] == ccipMessageSentEventSignature) {
//                 ccipMessageSentEventFound = true;
//                 break;
//             }
//         }
//         assertTrue(
//             ccipMessageSentEventFound,
//             "CCIPMessageSent event not found"
//         );
//     }
// }
