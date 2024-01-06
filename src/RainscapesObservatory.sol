// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IRainscapesObservatory} from "./interfaces/IRainscapesObservatory.sol";

contract RainscapesObservatory is IRainscapesObservatory {
    function getObservationWindow()
        public
        view
        returns (uint256 temporalWindow, uint256 spatialMin, uint256 spatialMax)
    {
        if (gasleft() < 90_000_000) {
            return (180, 200, 999); // Low gas version
        } else {
            return (280, 50, 999); // High gas version
        }
    }

    function getGasLeft() public view returns (uint256) {
        return gasleft();
    }
}
