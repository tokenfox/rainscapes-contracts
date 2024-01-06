// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {RainscapesRenderer} from "../src/RainscapesRenderer.sol";
import {DefaultScriptSource} from "../src/DefaultScriptSource.sol";
import {RainscapesObservatory} from "../src/RainscapesObservatory.sol";
import {LibString} from "@solady/src/utils/LibString.sol";

contract CreateTestBatch is Script {
    RainscapesRenderer public renderer;
    DefaultScriptSource public scriptSource;
    RainscapesObservatory public observatory;

    function setUp() public {
        observatory = new RainscapesObservatory();
        scriptSource = new DefaultScriptSource();
        renderer = new RainscapesRenderer(address(observatory), address(scriptSource));
    }

    function run() public {
        console2.log("Generate test batch");
        vm.roll(10000); // Start from block 10.000 to fill in blockhash history

        vm.createDir("generated/json", true);
        vm.createDir("generated/token-uri", true);
        vm.createDir("generated/image", true);
        vm.createDir("generated/html", true);

        for (uint256 i = 1; i <= 64; i++) {
            string memory seed = string(abi.encodePacked("seedprefix1234asd", LibString.toString(i)));
            uint256 tokenHash = _generateRandomUint256(seed);
            string memory json = renderer.tokenJSON(i, tokenHash);
            string memory txt = renderer.tokenURI(i, tokenHash);
            string memory svg = renderer.tokenImage(i, tokenHash);
            string memory html = renderer.tokenHTML(i, tokenHash);
            vm.writeFile(string.concat("generated/json/", LibString.toString(i), ".json"), json);
            vm.writeFile(string.concat("generated/token-uri/", LibString.toString(i), ".txt"), txt);
            vm.writeFile(string.concat("generated/image/", LibString.toString(i), ".svg"), svg);
            vm.writeFile(string.concat("generated/html/", LibString.toString(i), ".html"), html);
        }
    }

    function _generateRandomUint256(string memory seed) internal returns (uint256) {
        VmSafe.Wallet memory wallet = vm.createWallet(seed);
        return uint256(keccak256(abi.encode(wallet.publicKeyX, wallet.publicKeyY)));
    }
}
