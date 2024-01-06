// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRainscapesObservatory {
    function getObservationWindow()
        external
        view
        returns (uint256 temporalWindow, uint256 spatialMin, uint256 spatialMax);
}
