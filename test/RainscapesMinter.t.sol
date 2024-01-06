// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console2} from "forge-std/Test.sol";
import {ERC721Creator} from "@manifoldxyz/creator-core-solidity/ERC721Creator.sol";
import {GenerativeSeriesExtension} from "../src/GenerativeSeriesExtension.sol";
import {RainscapesMinter} from "../src/RainscapesMinter.sol";

contract RainscapesMinterTest is Test {
    RainscapesMinter public minter;
    ERC721Creator public creatorContract;
    VmSafe.Wallet public minter1;

    uint256 ALLOWLIST_MINT_OPENS_AT = 1000;
    uint256 PUBLIC_MINT_OPENS_AT = 2000;
    uint256 MINT_CLOSES_AT = 3000;

    receive() external payable {
        // To allow test contract receive plain Ether
    }

    function setUp() public {
        minter1 = vm.createWallet("minter1");
        creatorContract = new ERC721Creator("Rainscapes", "Rainscapes");
        GenerativeSeriesExtension generativeSeriesExtension = new GenerativeSeriesExtension();
        creatorContract.registerExtension(address(generativeSeriesExtension), "");
        minter = new RainscapesMinter(
            address(generativeSeriesExtension),
            address(creatorContract),
            0.05 ether
        );
        minter.scheduleMint(1000, 3000);
        generativeSeriesExtension.setMinter(address(creatorContract), address(minter));
        generativeSeriesExtension.createSeries(address(creatorContract), 64, address(0));
    }

    function testAllowlistMint() public {
        vm.warp(1001);

        address[] memory allowlistings = new address[](1);
        allowlistings[0] = minter1.addr;

        minter.changeAllowlist(allowlistings, true);
        minter.mintAllowlist{value: 0.05 ether}(minter1.addr);

        // Repeat mints will fail
        vm.expectRevert(bytes("Address has already minted"));
        minter.mintAllowlist{value: 0.05 ether}(minter1.addr);
    }

    function testPublicMintsOpenAt() public {
        uint256 opensAt = minter.publicMintOpensAt();

        assertEq(opensAt, 2000);
    }

    function test_allowlistMint_notAllowlisted() public {
        vm.warp(1001);

        vm.expectRevert(bytes("Not allowlisted"));
        minter.mintAllowlist{value: 0.05 ether}(minter1.addr);
    }

    function test_allowlistMint_mintIsNotYetOpen() public {
        vm.warp(999);

        vm.expectRevert(bytes("Allowlist mint is not open"));
        minter.mintAllowlist{value: 0.05 ether}(minter1.addr);
    }

    function testPublicMintIsNotOpen() public {
        vm.warp(PUBLIC_MINT_OPENS_AT - 1);
        vm.expectRevert(bytes("Public mint is not open"));
        minter.mintPublic{value: 0.05 ether}(minter1.addr);
    }

    function testPublicMintAlreadyClosed() public {
        vm.warp(MINT_CLOSES_AT);
        vm.expectRevert(bytes("Public mint is not open"));
        minter.mintPublic{value: 0.05 ether}(minter1.addr);
    }

    function testAllowlistMintAlreadyClosed() public {
        vm.warp(MINT_CLOSES_AT);
        vm.expectRevert(bytes("Allowlist mint is not open"));
        minter.mintAllowlist{value: 0.05 ether}(minter1.addr);
    }

    function testPublicMint() public {
        vm.warp(PUBLIC_MINT_OPENS_AT);
        minter.mintPublic{value: 0.05 ether}(minter1.addr);
    }

    function testPublicMinNotEnoughPaid() public {
        vm.warp(PUBLIC_MINT_OPENS_AT);
        vm.expectRevert(bytes("Insuffient payment"));
        minter.mintPublic{value: 0.0495 ether}(minter1.addr);
    }

    function testPublicPayingTooMuchIsAllowed() public {
        vm.warp(PUBLIC_MINT_OPENS_AT);
        minter.mintPublic{value: 0.051 ether}(minter1.addr);
    }

    function testWithdraw() public {
        vm.warp(ALLOWLIST_MINT_OPENS_AT);

        address[] memory allowlistings = new address[](1);
        allowlistings[0] = minter1.addr;

        minter.changeAllowlist(allowlistings, true);
        minter.mintAllowlist{value: 0.05 ether}(minter1.addr);

        uint256 startBalance = address(this).balance;
        assertEq(address(minter).balance, 0.05 ether);
        minter.withdraw();
        assertEq(address(minter).balance, 0 ether);
        assertEq(address(this).balance, startBalance + 0.05 ether);
    }
}
