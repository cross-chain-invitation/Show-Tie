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
    uint256 privateKey =
        0x1010101010101010101010101010101010101010101010101010101010101010;

    // function setUp() public {
    //     showtie = new Showtie(address(1), address(2), address(3));
    //     signer = vm.addr(privateKey); // 秘密鍵に対応するアドレスを生成
    // }

    function testVerify() public view {
        uint256 dappsId = 1;
        uint64 destinationChainSelector = 10344971235874465080;
        bytes memory message = abi.encodePacked(dappsId, destinationChainSelector);
        console.logBytes(message);
        bytes32 hashedMessage = keccak256(message);
        bytes
            memory signature = hex"7c86662e830fb67caa9de159bba5a0000ecb42092f7551f434879cdf26bb86db70d3946847ea5a5a67e0b7c63b60b5c34b73b0ac4c2f54984f0156dfbd0f0c9a1c";
        address signerAddress = 0x65150B5Fa861481651225Ef4412136DCBf696232;

        assertTrue(showtie.verify(hashedMessage, signature, signerAddress));
    }
}
