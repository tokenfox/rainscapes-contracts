// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGenerativeSeriesRenderer} from "./IGenerativeSeriesRenderer.sol";

interface IRendererAccess {
    function renderer(address creatorContractAddress) external view returns (address);
    function tokenHash(address creatorContractAddress, uint256 tokenId) external view returns (uint256);
}

contract RainscapesData {
    address public creatorContract;
    IRendererAccess public genSeriesExtension;

    constructor(address _creatorContract, address _genSeriesExtension) {
        creatorContract = _creatorContract;
        genSeriesExtension = IRendererAccess(_genSeriesExtension);
    }

    function renderer() external view returns (address) {
        return address(_getRenderer());
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        IGenerativeSeriesRenderer _renderer = _getRenderer();
        uint256 tokenHash = _getTokenHash(tokenId);
        return _renderer.tokenURI(tokenId, tokenHash);
    }

    function tokenHTML(uint256 tokenId) external view returns (string memory) {
        IGenerativeSeriesRenderer _renderer = _getRenderer();
        uint256 tokenHash = _getTokenHash(tokenId);
        return _renderer.tokenHTML(tokenId, tokenHash);
    }

    function tokenImage(uint256 tokenId) external view returns (string memory) {
        IGenerativeSeriesRenderer _renderer = _getRenderer();
        uint256 tokenHash = _getTokenHash(tokenId);
        return _renderer.tokenImage(tokenId, tokenHash);
    }

    function tokenJSON(uint256 tokenId) external view returns (string memory) {
        IGenerativeSeriesRenderer _renderer = _getRenderer();
        uint256 tokenHash = _getTokenHash(tokenId);
        return _renderer.tokenJSON(tokenId, tokenHash);
    }

    function _getRenderer() internal view returns (IGenerativeSeriesRenderer) {
        return IGenerativeSeriesRenderer(genSeriesExtension.renderer(creatorContract));
    }

    function _getTokenHash(uint256 tokenId) internal view returns (uint256) {
        return genSeriesExtension.tokenHash(creatorContract, tokenId);
    }
}
