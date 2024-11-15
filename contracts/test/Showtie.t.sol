// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Showtie} from "../src/Showtie.sol";

contract CounterTest is Test {
    Showtie public showtie;
    address public signProtocolContract = address(1);
    address public routerContract = address(2);
    address public linkContract = address(3);

    function setUp() public {
        showtie = new Showtie(signProtocolContract, routerContract, linkContract);
    }

    
}
