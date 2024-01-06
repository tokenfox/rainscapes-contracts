// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TraitsWithRarity.sol";

contract RainscapesTraits is TraitsWithRarity {
    uint8 constant BLOCKHASH_INDEX_X = 0;
    uint8 constant BLOCKHASH_INDEX_Y = 8;
    uint8 constant BLOCKHASH_INDEX_SHAPE = 0;
    uint8 constant BLOCKHASH_INDEX_COLOR = 8;

    uint8 constant TOKENHASH_INDEX_BIOME = 0;
    uint8 constant TOKENHASH_INDEX_ELEMENT = 8;
    uint8 constant TOKENHASH_INDEX_OFFSET_X = 16;
    uint8 constant TOKENHASH_INDEX_OFFSET_Y = 24;
    uint8 constant TOKENHASH_INDEX_INTENSITY = 32;

    struct BiomeProps {
        string[5] colors;
        string[2] backgrounds;
        uint256 maxColors;
        uint256 precipitation;
    }

    BiomeProps[] internal biomeProps;

    constructor() TraitsWithRarity(1000) {
        _createBiome();
        _createElement();
    }

    function _createBiome() private {
        TraitValue[] storage values = _initTrait("BIOME", "Biome", TOKENHASH_INDEX_BIOME);

        values.push(TraitValue(150, "Rainforest"));
        biomeProps.push(
            BiomeProps({
                colors: ["#7b753b", "#919b3e", "#535028", "#131612", "#3e3c34"],
                maxColors: 5,
                backgrounds: ["#345c34", "#1f3f2b"],
                precipitation: 225
            })
        );

        values.push(TraitValue(100, "Desert"));
        biomeProps.push(
            BiomeProps({
                colors: ["#f4b95e", "#e8ca8c", "#d0ac87", "#365a38", "#323715"],
                maxColors: 5,
                backgrounds: ["#ad8560", "#8b5b3e"],
                precipitation: 25
            })
        );

        values.push(TraitValue(100, "Tundra"));
        biomeProps.push(
            BiomeProps({
                colors: ["#6a4a34", "#7c6446", "#a46d09", "#a03725", "#db1a1b"],
                maxColors: 5,
                backgrounds: ["#b7975e", "#d2b28b"],
                precipitation: 25
            })
        );

        values.push(TraitValue(140, "Taiga"));
        biomeProps.push(
            BiomeProps({
                colors: ["#234c2e", "#143626", "#292f33", "#021c19", "#905020"],
                maxColors: 5,
                backgrounds: ["#7ccb6b", "#2d6f28"],
                precipitation: 100
            })
        );

        values.push(TraitValue(130, "Steppe"));
        biomeProps.push(
            BiomeProps({
                colors: ["#623e15", "#a6722d", "#324a15", "#49650d", "#ffe686"],
                maxColors: 5,
                backgrounds: ["#f9ce6b", "#dc9d47"],
                precipitation: 50
            })
        );

        values.push(TraitValue(100, "Savanna"));
        biomeProps.push(
            BiomeProps({
                colors: ["#7a6d07", "#505206", "#1f2409", "#6a7407", "#2a3419"],
                maxColors: 4,
                backgrounds: ["#bc6f09", "#6d3005"],
                precipitation: 120
            })
        );
        values.push(TraitValue(100, "Alpine"));
        biomeProps.push(
            BiomeProps({
                colors: ["#464646", "#d2d2d2", "#fefefe", "#3886b0", "#00bfff"],
                maxColors: 5,
                backgrounds: ["#607a9d", "#1c2331"],
                precipitation: 100
            })
        );

        values.push(TraitValue(60, "Polar"));
        biomeProps.push(
            BiomeProps({
                colors: ["#819fc3", "#8fc1e1", "#8fc1e1", "#a3b9cf", "#0d3256"],
                maxColors: 5,
                backgrounds: ["#4396c4", "#e3eaf5"],
                precipitation: 50
            })
        );

        values.push(TraitValue(50, "Chaparallal"));
        biomeProps.push(
            BiomeProps({
                colors: ["#5C704B", "#8F9A5C", "#9581a9", "#D9B14A", "#67A0A9"],
                maxColors: 5,
                backgrounds: ["#D3AB87", "#BBAE9E"],
                precipitation: 90
            })
        );

        values.push(TraitValue(20, "Mangrove"));
        biomeProps.push(
            BiomeProps({
                colors: ["#1e4a0f", "#288417", "#709748", "#8c9377", "#938e7d"],
                maxColors: 5,
                backgrounds: ["#60593c", "#0e0f09"],
                precipitation: 250
            })
        );
    }

    function _createElement() private {
        TraitValue[] storage values = _initTrait("ELEMENT", "Element", TOKENHASH_INDEX_ELEMENT);

        values.push(TraitValue(250, "Water"));
        values.push(TraitValue(250, "Air"));
        values.push(TraitValue(250, "Fire"));
        values.push(TraitValue(250, "Earth"));
    }
}
