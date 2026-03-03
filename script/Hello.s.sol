// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Hello} from "../src/Hello.sol";

contract HelloScript is Script {
    Hello public hello;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        hello = new Hello();

        vm.stopBroadcast();
    }
}
