// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IScriptSource {
    function script() external view returns (string memory);
}
