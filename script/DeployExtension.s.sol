// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {GenerativeSeriesExtension} from "../src/GenerativeSeriesExtension.sol";

contract DeployExtension is Script {
    uint256 private deployerPrivateKey;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    }

    function run() public {
        vm.broadcast(deployerPrivateKey);
        GenerativeSeriesExtension extension = new GenerativeSeriesExtension();
    }
}
