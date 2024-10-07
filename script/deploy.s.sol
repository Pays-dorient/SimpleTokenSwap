// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { SimpleTokenSwap } from "../src/SimpleTokenSwap.sol";
import { Script } from "forge-std/Script.sol";

contract DeploySimpleTokenSwap is Script {
    function run() external {
        vm.startBroadcast();
        new SimpleTokenSwap();
        vm.stopBroadcast();
    }
}
