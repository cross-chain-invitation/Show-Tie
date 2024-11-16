// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Showtie.sol"; // Showtieコントラクトのパス

contract DeployToLinea is Script {
    function run() public {
        // デプロイの開始
        vm.startBroadcast();

        // Showtieコントラクトのデプロイ
        Showtie showtie = new Showtie(
            address(1),
            0xB4431A6c63F72916151fEA2864DBB13b8ce80E8a,
            0xF64E6E064a71B45514691D397ad4204972cD6508,
            5719461335882077547,
            0x0,
            0x0,
            0x0
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
