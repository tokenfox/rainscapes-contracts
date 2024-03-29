// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {RainscapesRenderer} from "../src/RainscapesRenderer.sol";
import {RainscapesObservatory} from "../src/RainscapesObservatory.sol";
import {DefaultScriptSource} from "../src/DefaultScriptSource.sol";
import {IGenerativeSeriesExtension} from "../src/interfaces/IGenerativeSeriesExtension.sol";
import {RainscapesData} from "../src/RainscapesData.sol";

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
        // Start broadcast
        vm.startBroadcast(deployerPrivateKey);

        // Deploy observatory
        RainscapesObservatory observatory = new RainscapesObservatory();

        // Deploy script source
        DefaultScriptSource scriptSource = new DefaultScriptSource();

        // Deploy renderer
        RainscapesRenderer renderer = new RainscapesRenderer(address(observatory), address(scriptSource));

        // Create generative series
        genSeriesExtension.createSeries(creatorContractAddress, 64, address(renderer));

        // Set renderer in extension for the creator contract address
        genSeriesExtension.setRenderer(creatorContractAddress, address(renderer));

        // Deploy data contract
        RainscapesData data = new RainscapesData(creatorContractAddress, address(genSeriesExtension));
        console2.log("Data contract deployed to", address(data));

        // End broadcast
        vm.stopBroadcast();
    }
}
