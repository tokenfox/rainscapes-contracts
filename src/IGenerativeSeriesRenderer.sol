// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGenerativeSeriesRenderer {
    function tokenURI(uint256 tokenId, uint256 tokenHash) external view returns (string memory);
    function tokenImage(uint256 tokenId, uint256 tokenHash) external view returns (string memory);
    function tokenJSON(uint256 tokenId, uint256 tokenHash) external view returns (string memory);
    function tokenHTML(uint256 tokenId, uint256 tokenHash) external view returns (string memory);
}
