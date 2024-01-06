// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@solady/src/utils/LibString.sol";
import "@solady/src/utils/Base64.sol";
import "@solady/src/utils/FixedPointMathLib.sol";
import {Trigonometry} from "./libs/Trigonometry.sol";
import {IGenerativeSeriesRenderer} from "./interfaces/IGenerativeSeriesRenderer.sol";
import {RainscapesTraits} from "./RainscapesTraits.sol";
import {IRainscapesObservatory} from "./interfaces/IRainscapesObservatory.sol";
import {IScriptSource} from "./interfaces/IScriptSource.sol";

contract RainscapesRenderer is IGenerativeSeriesRenderer, RainscapesTraits, Ownable {
    struct TokenProperties {
        string name;
        uint256 tokenId;
        uint256 tokenHash;
        uint256 biome;
        uint256 element;
        int256 x;
        int256 y;
        int256 z;
        BiomeProps biomeProps;
    }

    struct WeatherProperties {
        uint256 observedAtBlock;
        uint256 observedAtTokenId;
        uint256 rainIntensity;
        uint256 rainDistance;
    }

    IRainscapesObservatory public observatory;
    IScriptSource public scriptSource;

    constructor(address _observatory, address _scriptSource) {
        observatory = IRainscapesObservatory(_observatory);
        scriptSource = IScriptSource(_scriptSource);
    }

    string public description =
        "Rainscapes is a collection of fully on-chain artworks of generative rain. The rain unfolds through the "
        "continuous block production of Optimism blockchain, creating the ambience of rain in a variety of natural settings. "
        "The artworks collectively observe the atmosphere of a world that is - at the same time - alien, and very much like ours.";

    modifier validTokenId(uint256 tokenId) {
        require(tokenId > 0 && tokenId <= 65, "Invalid tokenId");
        _;
    }

    function tokenProperties(uint256 tokenId, uint256 tokenHash) external view returns (TokenProperties memory) {
        return _getTokenProperties(tokenId, tokenHash);
    }

    function tokenJSON(uint256 tokenId, uint256 tokenHash)
        external
        view
        validTokenId(tokenId)
        returns (string memory)
    {
        return string(getJSONMetadata(tokenId, tokenHash, false, false));
    }

    function tokenImage(uint256 tokenId, uint256 tokenHash)
        external
        view
        validTokenId(tokenId)
        returns (string memory)
    {
        return string(_getImage(tokenId, tokenHash));
    }

    function tokenHTML(uint256 tokenId, uint256 tokenHash)
        external
        view
        validTokenId(tokenId)
        returns (string memory)
    {
        bytes memory image = _getImage(tokenId, tokenHash);
        return string(_getAnimation(tokenId, tokenHash, image));
    }

    function tokenURI(uint256 tokenId, uint256 tokenHash) external view validTokenId(tokenId) returns (string memory) {
        return LibString.concat(
            "data:application/json;base64,", Base64.encode(getJSONMetadata(tokenId, tokenHash, true, true))
        );
    }

    function tokenIdToXYZ(uint256 tokenId) public pure returns (int256, int256, int256) {
        uint256 phi = 809016994374947500;
        int256 sWAD = int256(FixedPointMathLib.WAD);
        int256 y = sWAD - int256(tokenId - 1) * (sWAD / 32);
        int256 radius = int256(FixedPointMathLib.sqrt(FixedPointMathLib.WAD - uint256(FixedPointMathLib.sMulWad(y, y))));
        uint256 theta = phi * (tokenId - 1);
        int256 x = FixedPointMathLib.sMulWad(Trigonometry.cos(theta), radius) * 1000000000;
        int256 z = FixedPointMathLib.sMulWad(Trigonometry.sin(theta), radius) * 1000000000;
        return (x, y, z);
    }

    function _getTokenProperties(uint256 tokenId, uint256 tokenHash) internal view returns (TokenProperties memory) {
        uint256 biomeIndex = getTrait("BIOME", tokenHash).valueIndex;
        uint256 elementIndex = getTrait("ELEMENT", tokenHash).valueIndex;
        (int256 x, int256 y, int256 z) = tokenIdToXYZ(tokenId);

        return TokenProperties({
            name: string(abi.encodePacked("Rainscape #", LibString.toString(tokenId))),
            tokenHash: tokenHash,
            tokenId: tokenId,
            biome: biomeIndex,
            element: elementIndex,
            x: x,
            y: y,
            z: z,
            biomeProps: biomeProps[biomeIndex]
        });
    }

    function _getWeatherProperties(BiomeProps memory biomeProps, uint256 tokenId, uint256 blockNumber)
        internal
        pure
        returns (WeatherProperties memory)
    {
        uint256 rainDistance = _getRainDistance(tokenId, blockNumber);

        WeatherProperties memory props = WeatherProperties({
            observedAtBlock: blockNumber,
            observedAtTokenId: tokenId,
            rainIntensity: (120 + biomeProps.precipitation) / 2,
            rainDistance: rainDistance
        });

        return props;
    }

    function _getRainDistance(uint256 tokenId, uint256 blockNumber) internal pure returns (uint256) {
        int256 minRainDistance = 400;
        int256 maxRainDistance = 12000;
        int256 delta = (maxRainDistance - minRainDistance) / 2;
        int256 average = (maxRainDistance + minRainDistance) / 2;
        uint256 blockOffset = (blockNumber % 8000) * Trigonometry.PI * 2 / 8000;
        int256 rainDistance = average
            + Trigonometry.cos(blockOffset + (tokenId - 1) * Trigonometry.PI * 2 / 64) * delta / 1000000000000000000;
        return uint256(rainDistance);
    }

    function getJSONMetadata(uint256 tokenId, uint256 tokenHash, bool withImage, bool withAnimation)
        public
        view
        returns (bytes memory)
    {
        TokenProperties memory props = _getTokenProperties(tokenId, tokenHash);
        bytes memory imageJson = bytes("");
        bytes memory animationJson = bytes("");
        bytes memory image = (withImage || withAnimation) ? _getImage(tokenId, tokenHash) : bytes("");
        if (withImage) {
            string memory imageBase64 = Base64.encode(image);
            imageJson = abi.encodePacked(",\"image\":\"data:image/svg+xml;base64,", imageBase64, "\"");
        }
        if (withAnimation) {
            bytes memory animation = _getAnimation(tokenId, tokenHash, image);
            string memory animationBase64 = Base64.encode(animation);
            animationJson = abi.encodePacked(",\"animation_url\":\"data:text/html;base64,", animationBase64, "\"");
        }

        return abi.encodePacked(
            "{\"name\":\"",
            props.name,
            "\",",
            "\"description\":\"",
            description,
            "\",",
            "\"attributes\":[",
            _getJsonAttributeNumeric("X", props.x),
            ",",
            _getJsonAttributeNumeric("Y", props.y),
            ",",
            _getJsonAttributeNumeric("Z", props.z),
            ",",
            _getJsonAttributes(tokenHash),
            "]",
            imageJson,
            animationJson,
            "}"
        );
    }

    function setObservatory(address _observatory) public onlyOwner {
        IRainscapesObservatory __observatory = IRainscapesObservatory(_observatory);
        (uint256 temporalWindow,,) = __observatory.getObservationWindow();
        require(temporalWindow > 0 && temporalWindow < 10000, "Observatory malfunction");
        observatory = __observatory;
    }

    function setScriptSource(address _scriptSource) public onlyOwner {
        scriptSource = IScriptSource(_scriptSource);
    }

    function setDescription(string memory _description) public onlyOwner {
        description = _description;
    }

    function _getJsonAttributeNumeric(string memory title, int256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(
            '{"display_type":"number","trait_type":"', title, '","value":', LibString.toString(value), "}"
        );
    }

    function _getJsonAttributes(uint256 tokenHash) internal view returns (bytes memory) {
        string[] memory traitKeys = getTraitKeys();
        bytes memory result = bytes("");

        for (uint256 i = 0; i < traitKeys.length; i++) {
            result = abi.encodePacked(
                result, _getTraitAsERC721JsonProperty(traitKeys[i], tokenHash), i + 1 < traitKeys.length ? "," : ""
            );
        }

        return result;
    }

    function _getImage(uint256 tokenId, uint256 tokenHash) internal view returns (bytes memory) {
        TokenProperties memory tokenProps = _getTokenProperties(tokenId, tokenHash);

        return abi.encodePacked(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" preserveaspectratio=\"xMidYMid meet\" viewBox=\"0 0 256 256\" style=\"background-color: #000000\">",
            _getStyles(tokenProps),
            _getDefs(tokenProps),
            "<clipPath id=\"rain-canvas-clip\"><rect x=\"0\" y=\"0\" width=\"256\" height=\"256\" /></clipPath>",
            "<g id=\"rain-canvas\" clip-path=\"url(#rain-canvas-clip)\">",
            _getBlockShapes(tokenProps),
            "</g>",
            "</svg>"
        );
    }

    function _getStyles(TokenProperties memory tokenProps) internal pure returns (bytes memory) {
        // Colors
        bytes memory colorStyles = bytes("");
        for (uint256 i = 0; i < tokenProps.biomeProps.maxColors; i++) {
            string memory color = tokenProps.biomeProps.colors[i];

            colorStyles = abi.encodePacked(
                colorStyles, ".c", LibString.toString(i), "{", "stroke:", color, ";", "fill:", color, "} "
            );
        }

        return abi.encodePacked(
            "<style type=\"text/css\">",
            colorStyles,
            ".f1 {filter:url(#b1)} ",
            ".f2 {filter:url(#b2)} ",
            ".f3 {filter:url(#b3)} ",
            ".f4 {filter:url(#b4)} " "</style>\n"
        );
    }

    function _getDefs(TokenProperties memory tokenProps) internal pure returns (bytes memory) {
        return abi.encodePacked(
            "<defs>",
            '<radialGradient id="gr" cx="50%" cy="50%" r="50%" fx="50%" fy="50%">',
            '<stop offset="0%" style="stop-color:',
            tokenProps.biomeProps.backgrounds[0],
            '; stop-opacity:1"/>',
            '<stop offset="100%" style="stop-color:',
            tokenProps.biomeProps.backgrounds[1],
            '; stop-opacity:1"/>',
            "</radialGradient>",
            '<filter id="b1" x="0" y="0" width="100%" height="100%"><feGaussianBlur in="SourceGraphic" stdDeviation="0.2"/></filter>'
            '<filter id="b2" x="0" y="0" width="100%" height="100%"><feGaussianBlur in="SourceGraphic" stdDeviation="0.4"/></filter>'
            '<filter id="b3" x="0" y="0" width="100%" height="100%"><feGaussianBlur in="SourceGraphic" stdDeviation="0.8"/></filter>'
            '<filter id="b4" x="0" y="0" width="100%" height="100%"><feGaussianBlur in="SourceGraphic" stdDeviation="1.6"/></filter>'
            '<circle id="s10" cx="0" cy="0" r="8" stroke-width="0"/>',
            '<circle id="s11" cx="0" cy="0" r="8" fill="none" stroke-width="2"/>',
            '<polygon id="s20" points="0,-12,0,12" fill="none" stroke-width="4"/>'
            '<polygon id="s21" points="-4,-12,4,-12,4,12,-4,12" stroke-width="0"/>'
            '<polygon id="s30" points="0,-8 6.4,8 -6.4,8" stroke-width="0"/>'
            '<polygon id="s31" points="0,-8 6.4,8 -6.4,8" fill="none" stroke-width="2"/>'
            '<polygon id="s40" points="-7.2,-8 7.2,-8 7.2,8 -7.2,8" stroke-width="0"/>'
            '<polygon id="s41" points="-7.2,-8 7.2,-8 7.2,8 -7.2,8" fill="none" stroke-width="2"/></defs>',
            '<rect x="0" y="0" width="256" height="256" style="fill:url(#gr)"/>\n'
        );
    }

    function _getBlockShapes(TokenProperties memory tokenProps) internal view returns (string memory) {
        (uint256 temporalWindow, uint256 spatialMin, uint256 spatialMax) = observatory.getObservationWindow();
        uint256 opacityStep = (spatialMax - spatialMin) / temporalWindow;

        uint256 _blockNumber = block.number - temporalWindow;
        uint256 _highestBlockNumber = block.number - 1;
        string memory result = "";
        uint256 opacity = spatialMin;
        uint256 index = 0;
        unchecked {
            while (_blockNumber < _highestBlockNumber) {
                if (opacity < 999 - opacityStep) {
                    opacity += opacityStep;
                }
                ++_blockNumber;
                ++index;

                bytes32 _blockHash = _getBlockHashOrSynthesize(_blockNumber);
                uint256 _blockHashFragment = uint256(_blockHash) >> (tokenProps.tokenId * 4);
                if (tokenProps.tokenId > 60) {
                    // Recycle lowest bits on overflow
                    _blockHashFragment += (uint256(_blockHash) & 65535) << (256 - tokenProps.tokenId * 4);
                }
                result =
                    LibString.concat(result, _createShapeByBlockHashFragment(tokenProps, _blockHashFragment, opacity));
            }
        }

        return result;
    }

    function _createShapeByBlockHashFragment(
        TokenProperties memory tokenProps,
        uint256 blockHashFragment,
        uint256 opacity
    ) internal pure returns (string memory) {
        uint256 tokenHash = tokenProps.tokenHash;
        uint256 seed1 = (tokenHash >> TOKENHASH_INDEX_OFFSET_X) % 16384;
        uint256 seed2 = (tokenHash >> TOKENHASH_INDEX_OFFSET_Y) % 16384;
        uint256 seed3 = (tokenHash >> TOKENHASH_INDEX_INTENSITY) % 256;

        return LibString.concat(
            _createShapeOuter(blockHashFragment, opacity, seed1, seed2, seed3),
            _createShapeInner(tokenProps, blockHashFragment, opacity)
        );
    }

    function _createShapeOuter(
        uint256 blockHashFragment,
        uint256 opacity,
        uint256 xOffset,
        uint256 yOffset,
        uint256 intensity
    ) internal pure returns (string memory) {
        unchecked {
            uint256 x = (blockHashFragment >> BLOCKHASH_INDEX_X) % 256;
            uint256 y = (blockHashFragment >> BLOCKHASH_INDEX_Y) % 256;
            int256 z = _lookupOrientation(x, y, xOffset, yOffset, intensity);
            int256 rotation = (z * 360 / 1000000000000000000) % 360;

            return string(
                abi.encodePacked(
                    "<g transform=\"translate(",
                    LibString.toString(x),
                    ",",
                    LibString.toString(y),
                    ") rotate(",
                    LibString.toString(rotation),
                    ")\" opacity=\"0.",
                    _leftPadThreeZeroes(opacity),
                    "\">"
                )
            );
        }
    }

    function _leftPadThreeZeroes(uint256 value) internal pure returns (string memory) {
        if (value >= 100) {
            return LibString.toString(value);
        }
        if (value >= 10) {
            return LibString.concat("0", LibString.toString(value));
        } else {
            return LibString.concat("00", LibString.toString(value));
        }
    }

    function _createShapeInner(TokenProperties memory tokenProps, uint256 _blockHashFragment, uint256 opacity)
        internal
        pure
        returns (string memory)
    {
        uint256 elementIndex = tokenProps.element;
        uint256 shapeIndex = (_blockHashFragment >> BLOCKHASH_INDEX_SHAPE) % 2 + (elementIndex + 1) * 10;
        uint256 colorIndex = (_blockHashFragment >> BLOCKHASH_INDEX_COLOR) % tokenProps.biomeProps.maxColors;
        uint256 filterId = _getFilterId(opacity);
        uint256 scale = _getScale(opacity);

        return string(
            abi.encodePacked(
                "<use href=\"#s",
                LibString.toString(shapeIndex),
                "\" ",
                "class=\"c",
                LibString.toString(colorIndex),
                " f",
                LibString.toString(filterId),
                "\" ",
                "transform=\"scale(0.",
                LibString.toString(scale),
                ")\"/></g>\n"
            )
        );
    }

    function _getFilterId(uint256 opacity) internal pure returns (uint256) {
        uint256 filterId = 0;
        if (opacity < 600) {
            filterId = 1;
        }
        if (opacity < 500) {
            filterId = 2;
        }
        if (opacity < 400) {
            filterId = 3;
        }
        if (opacity < 300) {
            filterId = 4;
        }

        return filterId;
    }

    function _getScale(uint256 opacity) internal pure returns (uint256) {
        unchecked {
            return (opacity < 600) ? (1100 - opacity) : 500;
        }
    }

    function _lookupOrientation(uint256 x, uint256 y, uint256 xo, uint256 yo, uint256 zo)
        internal
        pure
        returns (int256)
    {
        unchecked {
            uint256 scale = 1 + zo % 2;
            uint256 xf = (x + xo) * Trigonometry.PI * scale / 16 / 256;
            uint256 yf = (y + yo) * Trigonometry.PI * scale / 16 / 256;

            return Trigonometry.sin(xf) + Trigonometry.sin(yf) + Trigonometry.cos(xf) + Trigonometry.cos(yf);
        }
    }

    function _getBlockHashOrSynthesize(uint256 blockNumber) internal view returns (bytes32) {
        bytes32 _blockHash = blockhash(blockNumber);

        // Optimism supports block hash history to up to 10.000 blocks
        // For the unlikely case this is radically lowered, we can
        // hit a block hash of 0. In this case, we will synthesize hashes
        if (_blockHash == bytes32(0)) {
            _blockHash = _synthesizeHash(blockNumber);
        }

        return _blockHash;
    }

    function _synthesizeHash(uint256 blockNumber) internal view returns (bytes32) {
        uint256 index = block.number - blockNumber;
        uint256 indexFactor = index / 256;

        return keccak256(
            abi.encodePacked(blockhash(block.number - index % 256), blockhash(block.number - index % 256 - indexFactor))
        );
    }

    function _getAnimation(uint256 tokenId, uint256 tokenHash, bytes memory image)
        internal
        view
        returns (bytes memory)
    {
        uint256 biomeIndex = getTrait("BIOME", tokenHash).valueIndex;
        WeatherProperties memory weatherProps = _getWeatherProperties(biomeProps[biomeIndex], tokenId, block.number);

        return abi.encodePacked(
            htmlPrefix,
            image,
            '<script type="text/javascript">',
            "const weather={rainIntensity:",
            LibString.toString(weatherProps.rainIntensity),
            ",rainDistance:",
            LibString.toString(weatherProps.rainDistance),
            "};\n",
            scriptSource.script(),
            "</script>",
            htmlSuffix
        );
    }

    string public htmlPrefix =
        '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Rainscape</title><style>body,html,svg{margin:0;padding:0;height:100%;text-align:center;background-color:#000}html{overflow:hidden}svg{pointer-events:none;user-select:none}.play-btn{position:absolute;left:50%;top:50%;border-style:solid;border-width:1rem 0 1rem 1.5rem;margin-left:-.55rem;margin-top:-1rem;border-color:transparent transparent transparent rgba(32,32,32,.5);cursor:pointer}.play-circle{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);width:4rem;height:4rem;border-radius:50%;background-color:rgba(255,255,255,.3)}#controls{opacity:0;transition:opacity 1s ease-in-out}</style></head><body><div id="controls"><div class="play-circle"></div><div class="play-btn"></div></div>';
    string public htmlSuffix = "</body></html>";
}
