// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {RainscapesRenderer} from "../src/RainscapesRenderer.sol";
import {RainscapesObservatory} from "../src/RainscapesObservatory.sol";
import {DefaultScriptSource} from "../src/DefaultScriptSource.sol";
import {IGenerativeSeriesExtension} from "../src/interfaces/IGenerativeSeriesExtension.sol";

contract DeployRainscapes is Script {
    uint256 private deployerPrivateKey;
    address private creatorContractAddress;
    IGenerativeSeriesExtension private genSeriesExtension;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        creatorContractAddress = vm.envAddress("MANIFOLD_CREATOR_CONTRACT_ADDRESS");
        genSeriesExtension = IGenerativeSeriesExtension(
            vm.envAddress("MANIFOLD_EXTENSION_ADDRESS")
        );
    }

    function run() public {
        vm.startBroadcast();

        // Deploy observatory
        RainscapesObservatory observatory = new RainscapesObservatory();

        // Deploy script source
        DefaultScriptSource scriptSource = new DefaultScriptSource();

        // Deploy renderer
        RainscapesRenderer renderer = new RainscapesRenderer(address(observatory), address(scriptSource));

        // Set renderer in extension for the creator contract address
        genSeriesExtension.setRenderer(creatorContractAddress, address(renderer));
    }
}
