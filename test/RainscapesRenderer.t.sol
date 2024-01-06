// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console2} from "forge-std/Test.sol";
import "@solady/src/utils/LibString.sol";
import {RainscapesRenderer} from "../src/RainscapesRenderer.sol";
import {DefaultScriptSource} from "../src/DefaultScriptSource.sol";
import {MockObservatory} from "./mocks/MockObservatory.sol";

contract RainscapesRendererTest is Test {
    RainscapesRenderer public renderer;
    MockObservatory public observatory;
    DefaultScriptSource public scriptSource;

    function setUp() public {
        observatory = new MockObservatory();
        scriptSource = new DefaultScriptSource();
        renderer = new RainscapesRenderer(address(observatory), address(scriptSource));
    }

    function testSetObservatory() public {
        MockObservatory _observatory = new MockObservatory();
        renderer.setObservatory(address(_observatory));

        assertEq(address(renderer.observatory()), address(_observatory));
    }

    function testGasProfileHighRes() public {
        vm.roll(10000);
        observatory.setObservationWindow(280, 50, 999);

        uint256 gas1 = gasleft();
        renderer.tokenURI(1, 0x29d48cdcf9e05370402917c391130e22bd8bbf0a8f70fd32bcb01113382b378f);
        uint256 gasUsed = gas1 - gasleft();
        uint256 maxGasUsage = 150_000_000;
        console2.log("gas used: ", gasUsed, ", percent: ", (gasUsed / (maxGasUsage / 100)));
        assertLt(gasUsed, maxGasUsage);
    }

    function testGasProfileLowRes() public {
        vm.roll(10000);
        observatory.setObservationWindow(180, 200, 999);

        uint256 gas1 = gasleft();
        renderer.tokenURI(1, 0x29d48cdcf9e05370402917c391130e22bd8bbf0a8f70fd32bcb01113382b378f);
        uint256 gasUsed = gas1 - gasleft();
        uint256 maxGasUsage = 50_000_000;
        console2.log("gas used: ", gasUsed, ", percent: ", (gasUsed / (maxGasUsage / 100)));
        assertLt(gasUsed, maxGasUsage);
    }
}
