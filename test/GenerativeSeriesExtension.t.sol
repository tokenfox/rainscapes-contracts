// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console2} from "forge-std/Test.sol";
import {ERC721Creator} from "@manifoldxyz/creator-core-solidity/ERC721Creator.sol";
import {GenerativeSeriesExtension} from "../src/GenerativeSeriesExtension.sol";
import {UnrevealedRenderer} from "../src/UnrevealedRenderer.sol";

contract GenerativeSeriesExtensionTest is Test {
    ERC721Creator public creatorContract;
    GenerativeSeriesExtension public genExtension;
    UnrevealedRenderer public renderer;

    function setUp() public {
        creatorContract = new ERC721Creator("GenToken", "GEN");
        genExtension = new GenerativeSeriesExtension();
        renderer = new UnrevealedRenderer();
    }

    function testCreateSeries(uint16 maxSupply) public {
        vm.assume(maxSupply > 0);

        genExtension.createSeries(address(creatorContract), maxSupply, address(renderer));

        uint16 currentSupply = genExtension.currentSupply(address(creatorContract));
        uint16 _maxSupply = genExtension.maxSupply(address(creatorContract));

        assertEq(currentSupply, 0, "Initial supply should be 0");
        assertEq(_maxSupply, maxSupply, "Max supply should be set correctly");

        // Create cannot be called again on initialized series
        vm.expectRevert(bytes("Series already initialized"));
        genExtension.createSeries(address(creatorContract), maxSupply, address(renderer));
    }

    function testCreateSeriesNotAdmin() public {
        vm.prank(address(0x1));
        vm.expectRevert(bytes("Wallet is not an administrator for contract"));
        genExtension.createSeries(address(creatorContract), 1, address(renderer));
    }
}
