// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {RainscapesMinter} from "../src/RainscapesMinter.sol";
import {IGenerativeSeriesExtension} from "../src/interfaces/IGenerativeSeriesExtension.sol";

contract DeployMinter is Script {
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

        // Deploy minter
        RainscapesMinter minter = new RainscapesMinter(
            address(genSeriesExtension),
            creatorContractAddress,
            0.05 ether // mint price
        );

        // Set minter to generative series
        genSeriesExtension.setMinter(creatorContractAddress, address(minter));

        // Configure allowlist
        // Demo setup adds deployer to allowlist
        address[] memory allowlistedAddresses = new address[](1);
        allowlistedAddresses[0] = address(this);
        minter.changeAllowlist(allowlistedAddresses, true);

        // Schedule minting:
        // Demo setup starts minting in 1 hours with
        // 1 hour allowlist and 1 hour whitelist
        uint256 timestampNow = minter.blockTimeStampNow();
        minter.scheduleMint(
            timestampNow + 60 * 60 * 1,
            timestampNow + 60 * 60 * 3
        );

        // End broadcast
        vm.stopBroadcast();
    }
}
