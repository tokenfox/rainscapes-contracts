// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console2} from "forge-std/Test.sol";
import {LibString} from "@solady/src/utils/LibString.sol";
import {UnrevealedRenderer} from "../src/UnrevealedRenderer.sol";

contract UnrevealedRendererTest is Test {
    UnrevealedRenderer public renderer;

    function setUp() public {
        renderer = new UnrevealedRenderer();
    }

    function testImage() public {
        string memory image = renderer.tokenImage(0, 0);

        assertTrue(LibString.startsWith(image, '<svg xmlns'));
    }

    function testTokenURI() public {
        string memory tokenURI = renderer.tokenURI(0, 0);

        assertTrue(LibString.startsWith(tokenURI, 'data:application/json;base64,'));
    }

    function testTokenJSON() public {
        string memory json = renderer.tokenJSON(0, 0);

        assertTrue(LibString.startsWith(json, '{"name": "'));
    }

    function testTokenHTML() public {
        string memory html = renderer.tokenHTML(0, 0);

        assertTrue(LibString.startsWith(html, '<!DOCTYPE html><html>'));
    }
}
