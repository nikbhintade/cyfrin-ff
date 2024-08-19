// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); // this is something called
        // cheatcode - read foundry docs to learn about that more.
        // startBroadcast - tells foundry to send all that comes
        // after it to RPC url

        SimpleStorage simpleStorage = new SimpleStorage();
        // create new instance of SimpleStorage

        vm.stopBroadcast();
        // this stops braodcasting to PRC url

        return simpleStorage;
    }
}
