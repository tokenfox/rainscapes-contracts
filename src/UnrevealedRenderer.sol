// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGenerativeSeriesRenderer} from "./IGenerativeSeriesRenderer.sol";
import "@solady/src/utils/LibString.sol";
import "@solady/src/utils/Base64.sol";

contract UnrevealedRenderer is IGenerativeSeriesRenderer {
    constructor() {}

    function tokenJSON(uint256 tokenId, uint256 tokenHash) external view returns (string memory) {
        return string(_getTokenMetadata(tokenId, tokenHash));
    }

    function tokenHTML(uint256 tokenId, uint256 tokenHash) external view returns (string memory) {
        return string(_getTokenAnimation(tokenId, tokenHash));
    }

    function tokenImage(uint256 tokenId, uint256 tokenHash) external view returns (string memory) {
        return string(_getTokenImage(tokenId, tokenHash));
    }

    function tokenURI(uint256 tokenId, uint256 tokenHash) external view returns (string memory) {
        return LibString.concat("data:application/json;base64,", Base64.encode(_getTokenMetadata(tokenId, tokenHash)));
    }

    function _getTokenMetadata(uint256 tokenId, uint256 tokenHash) internal view returns (bytes memory) {
        return abi.encodePacked(
            "{\"name\": \"",
            _unrevealedTitle,
            "\",",
            "\"image\": \"data:image/svg+xml;base64,",
            Base64.encode(_getTokenImage(tokenId, tokenHash)),
            "\",",
            "\"animation_url\": \"data:text/html;base64,",
            Base64.encode(_getTokenAnimation(tokenId, tokenHash)),
            "\"",
            "}"
        );
    }

    function _getTokenAnimation(uint256 tokenId, uint256 tokenHash) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">",
            "<title>",
            _unrevealedTitle,
            "</title>",
            "<style>html, body, svg { background-color: #000000; width: 100%; height: 100%; margin: 0; padding: 0; }</style></head><body>",
            _getTokenImage(tokenId, tokenHash),
            "</body></html>"
        );
    }

    function _getTokenImage(uint256, /* tokenId */ uint256 /* tokenHash */ ) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"100%\" height=\"100%\" preserveaspectratio=\"xMidYMid meet\" viewBox=\"0 0 256 256\" style=\"background-color: #000000\">\n",
            "<foreignObject x=\"0\" y=\"0\" width='100%' height='100%'>",
            _unrevealedContentPrefix,
            _unrevealedContent,
            _unrevealedContentSuffix,
            "</foreignObject></svg>"
        );
    }

    string internal _unrevealedTitle =
        "\u25b2\u25b3\u0020\u25b3\u0020\u25b2\u0020\u25b2\u0020\u0020\u25b2\u25b3\u0020\u0020\u0020\u0020\u25b3";
    string internal _unrevealedContentPrefix =
        "<div xmlns=\"http://www.w3.org/1999/xhtml\"><pre style=\"color: #ffffff;\">";
    string internal _unrevealedContent =
        "&#160;&#160;  \u25b2\u25b3      \u25b3\u25b3 \u25b2 \u25b3\u25b2 \u25b2             <br />&#160;&#160;\u25b3 \u25b3   \u25b3\u25b2  \u25b2  \u25b3\u25b3   \u25b2 \u25b2  \u25b2\u25b3       <br />&#160;&#160;    \u25b2  \u25b3       \u25b2    \u25b3\u25b2\u25b3 \u25b3\u25b2      <br />&#160;&#160;            \u25b3   \u25b2  \u25b3\u25b2      \u25b3    <br />&#160;&#160;  \u25b3    \u25b2     \u25b3    \u25b3         \u25b3\u25b3  <br />&#160;&#160;\u25b2 \u25b3           \u25b3 \u25b2\u25b2    \u25b2 \u25b3       <br />&#160;&#160;  \u25b2      \u25b2   \u25b3  \u25b2 \u25b3\u25b2  \u25b3 \u25b2       <br />&#160;&#160;                    \u25b2\u25b2          <br />&#160;&#160;  \u25b2       \u25b2\u25b3\u25b3          \u25b3 \u25b3 \u25b2    <br />&#160;&#160;\u25b3\u25b3  \u25b3\u25b2        \u25b3\u25b2\u25b3          \u25b3 \u25b2  <br />&#160;&#160;\u25b2 \u25b2            \u25b2 \u25b2 \u25b2     \u25b3      <br />&#160;&#160;\u25b2     \u25b3\u25b3        \u25b3   \u25b3\u25b3     \u25b2    <br />&#160;&#160;  \u25b2  \u25b2          \u25b2 \u25b3 \u25b3\u25b3   \u25b3      <br />&#160;&#160;  \u25b3\u25b3      \u25b3\u25b2  \u25b2 \u25b2   \u25b2      \u25b2\u25b2   <br />&#160;&#160;                  \u25b2             <br />&#160;&#160;                    \u25b2    \u25b3      <br /><br />";
    string internal _unrevealedContentSuffix = "</pre></div>";
}
