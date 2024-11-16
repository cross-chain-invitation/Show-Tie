// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol"; // FoundryのTestライブラリ
import "solady/utils/ECDSA.sol";
import "../src/Showtie.sol";
import "forge-std/console.sol";

contract VerifyECDSASignatureTest is Test {
    using ECDSA for bytes32;

    Showtie public showtie;
    address private signer;
    uint256 privateKey = 0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        // showtie = new Showtie(address(1), address(2), address(3), 1, 2, 3, 4);
        // signer = vm.addr(privateKey); // 秘密鍵に対応するアドレスを生成
    }
}
