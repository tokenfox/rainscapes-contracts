// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGenerativeSeriesExtension {
    function createSeries(address creatorContractAddress, uint16 _maxSupply, address _renderer) external;
    function setRenderer(address creatorContractAddress, address _renderer) external;
    function setMinter(address creatorContractAddress, address _minter) external;
    function minter(address creatorContractAddress) external view returns (address);
    function mint(address creatorContractAddress, address to) external;
    function maxSupply(address creatorContractAddress) external view returns (uint16);
    function currentSupply(address creatorContractAddress) external view returns (uint16);
}
