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
            address(1),
            0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            16015286601757825753,
            0x2ed,
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
        vm.startBroadcast();

        address showtieAddress = 0x3eD3e37309d9FBC425258b44AF87B673E52c7dfA; //Sepolia Contract
        Showtie showtie = Showtie(showtieAddress);

        // createInvitation関数の引数を設定
        uint64 destinationChainSelector = 10344971235874465080; //Base
        address targetContract = 0x582BeC27D96Ada0e958048208DD2953a6B642C6e; // Base Contract
        uint256 dappsId = 1;
        bytes memory signature =
            hex"7c86662e830fb67caa9de159bba5a0000ecb42092f7551f434879cdf26bb86db70d3946847ea5a5a67e0b7c63b60b5c34b73b0ac4c2f54984f0156dfbd0f0c9a1c";

        // 関数を実行
        showtie.createInvitation(destinationChainSelector, targetContract, dappsId, signature);

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
