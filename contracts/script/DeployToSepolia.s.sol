// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Showtie.sol"; // Showtieコントラクトのパス
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract DeployToSepolia is Script {
    LinkTokenInterface private s_linkToken = LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    function run() public {
        // デプロイの開始
        vm.startBroadcast();


        // Showtieコントラクトのデプロイ
        Showtie showtie = new Showtie(
            0x878c92FD89d8E0B93Dc0a3c907A2adc7577e39c5,
            0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            16015286601757825753,
            0x2ed,
            0x0,
            0x0
        );

        // デプロイされたコントラクトアドレスをコンソールに出力
        console.log("Showtie deployed at:", address(showtie));

        s_linkToken.transfer(address(showtie), 1000000000000000000);

        // デプロイの終了
        vm.stopBroadcast();
    }
}

contract callCCIP is Script {
    function run() public {
        address showtieAddress = 0x582BeC27D96Ada0e958048208DD2953a6B642C6e; //Sepolia Contract
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);
        uint256 amount = 1000000000000000000; // 1 LINK
        vm.startBroadcast();

        Showtie showtie = Showtie(showtieAddress);

        // createInvitation関数の引数を設定
        uint64 destinationChainSelector = 10344971235874465080; //Base
        address targetContract = 0x15B891DeC2a285753E52E2c697fF372aa2741218; // Base Contract
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
