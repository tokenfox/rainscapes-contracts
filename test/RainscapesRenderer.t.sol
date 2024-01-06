// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console2} from "forge-std/Test.sol";
import "@solady/src/utils/LibString.sol";
import {RainscapesRenderer} from "../src/RainscapesRenderer.sol";
import {RainscapesObservatory} from "../src/RainscapesObservatory.sol";
import {NativeScriptSource} from "../src/NativeScriptSource.sol";

contract RainscapesRendererTest is Test {
    RainscapesRenderer public renderer;
    RainscapesObservatory public observatory;
    NativeScriptSource public scriptSource;

    function setUp() public {
        observatory = new RainscapesObservatory();
        scriptSource = new NativeScriptSource();
        renderer = new RainscapesRenderer(address(observatory), address(scriptSource));
    }

    function testSetObservatory() public {
        RainscapesObservatory _observatory = new RainscapesObservatory();
        renderer.setObservatory(address(_observatory));
    }

    function testGasProfile() public {
        vm.roll(10000);

        uint256 gas1 = gasleft();
        renderer.tokenURI(1, 0x29d48cdcf9e05370402917c391130e22bd8bbf0a8f70fd32bcb01113382b378f);
        uint256 gasUsed = gas1 - gasleft();
        uint256 maxGasUsage = 40000000;
        console2.log("gas used: ", gasUsed, ", percent: ", (gasUsed / (maxGasUsage / 100)));
        //assertLt(gasUsed, maxGasUsage);
    }
}
