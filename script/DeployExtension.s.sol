// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {GenerativeSeriesExtension} from "../src/GenerativeSeriesExtension.sol";

contract DeployExtension is Script {
    uint256 private deployerPrivateKey;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    }

    function run() public {
        vm.broadcast(deployerPrivateKey);

        // Deploy extension
        GenerativeSeriesExtension extension = new GenerativeSeriesExtension();
        console2.log('Extension deployed at', address(extension));
    }
}
