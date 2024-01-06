// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IRainscapesObservatory} from '../../src/IRainscapesObservatory.sol';

contract MockObservatory is IRainscapesObservatory {
    uint256 public temporalWindow = 100;
    uint256 public spatialMin = 50;
    uint256 public spatialMax = 999;

    function setObservationWindow(
        uint256 _temporalWindow,
        uint256 _spatialMin,
        uint256 _spatialMax
    ) public {
        temporalWindow = _temporalWindow;
        spatialMin = _spatialMin;
        spatialMax = _spatialMax;
    }

    function getObservationWindow()
        public
        view
        returns (uint256 _temporalWindow, uint256 _spatialMin, uint256 _spatialMax)
    {
        return (temporalWindow, spatialMin, spatialMax);
    }
}