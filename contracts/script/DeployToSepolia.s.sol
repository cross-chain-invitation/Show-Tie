// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Showtie.sol"; // Showtieコントラクトのパス

contract DeployToSepolia is Script {
    function run() public {
        // デプロイの開始
        vm.startBroadcast();

        // Showtieコントラクトのデプロイ
        Showtie showtie = new Showtie(
            address(1), 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, 0x779877A7B0D9E8603169DdbD7836e478b4624789
        );

        // デプロイされたコントラクトアドレスをコンソールに出力
        console.log("Showtie deployed at:", address(showtie));

        // デプロイの終了
        vm.stopBroadcast();
    }
}

contract callCCIP is Script {
    function run() public {
        // デプロイの開始
        vm.startBroadcast();

        // address showtieAddress = 0x900E61f9CF646453aa208e423372B87FA0C53846; // 適切なアドレスに置き換える
        // Showtie showtie = Showtie(showtieAddress);

        // // createInvitation関数の引数を設定
        // uint64 destinationChainSelector = 1; // 適当なチェーンセレクター
        // address targetContract = 0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef; // 適当なターゲットコントラクトアドレス
        // string memory text = "Hello, this is an invitation!"; // 任意のテキスト

        // // 関数を実行
        // showtie.createInvitation(destinationChainSelector, targetContract, text);

        // デプロイの終了
        vm.stopBroadcast();
    }
}

contract receiveText is Script {
    function run() public {
        // RPC通信を開始
        vm.startBroadcast();

        // 既存のデプロイ済みShowtieコントラクトのアドレスを設定
        address showtieAddress = 0x900E61f9CF646453aa208e423372B87FA0C53846; // 適切なアドレスに置き換える
        Showtie showtie = Showtie(showtieAddress);

        // getLastReceivedText関数を呼び出して返り値を取得
        string memory lastText = showtie.getLastReceivedText();

        // コンソールに出力
        console.log("Last received text:", lastText);

        // RPC通信を終了
        vm.stopBroadcast();
    }
}
