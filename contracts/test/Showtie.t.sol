// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Showtie} from "../src/Showtie.sol";

contract CounterTest is Test {
    Showtie public showtie;
    address public signProtocolContract = address(1);
    address public ccipContract = address(2);

    function setUp() public {
        showtie = new Showtie(signProtocolContract, ccipContract);
    }

    
}
