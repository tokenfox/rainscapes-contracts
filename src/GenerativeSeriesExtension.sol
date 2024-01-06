// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {AdminControl} from "@manifoldxyz/libraries-solidity/contracts/access/AdminControl.sol";
import {IERC721CreatorCore} from "@manifoldxyz/creator-core-solidity/core/IERC721CreatorCore.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ICreatorExtensionTokenURI} from "@manifoldxyz/creator-core-solidity/extensions/ICreatorExtensionTokenURI.sol";
import {IGenerativeSeriesRenderer} from "./IGenerativeSeriesRenderer.sol";
import {IGenerativeSeriesExtension} from "./IGenerativeSeriesExtension.sol";

contract GenerativeSeriesExtension is AdminControl, ICreatorExtensionTokenURI, IGenerativeSeriesExtension {
    mapping(address => uint16) public maxSupply;
    mapping(address => uint16) public currentSupply;
    mapping(address => address) public minter;
    mapping(address => address) public renderer;
    mapping(address => bool) public frozen;
    mapping(address => mapping(uint256 => uint256)) public tokenHash;

    modifier creatorAdminRequired(address creatorContractAddress) {
        AdminControl creatorCoreContract = AdminControl(creatorContractAddress);
        require(creatorCoreContract.isAdmin(msg.sender), "Wallet is not an administrator for contract");
        _;
    }

    modifier seriesNotInitialized(address creatorContractAddress) {
        require(maxSupply[creatorContractAddress] == 0, "Series already initialized");
        _;
    }

    modifier isNotFrozen(address creatorContractAddress) {
        require(!frozen[creatorContractAddress], "Series is frozen");
        _;
    }

    modifier rendererIsSet(address creatorContractAddress) {
        require(renderer[creatorContractAddress] != address(0), "Renderer not set");
        _;
    }

    modifier seriesHasSupplyLeft(address creatorContractAddress) {
        uint16 _maxSupply = maxSupply[creatorContractAddress];
        uint16 _currentSupply = currentSupply[creatorContractAddress];

        require(_maxSupply != 0, "Series not initialized");
        require(_currentSupply < _maxSupply, "Series has no supply left");
        _;
    }

    modifier onlyMinter(address creatorContractAddress) {
        require(msg.sender == minter[creatorContractAddress], "Only minter can call");
        _;
    }

    function tokenURI(address creatorContractAddress, uint256 tokenId)
        external
        view
        rendererIsSet(creatorContractAddress)
        returns (string memory)
    {
        (IGenerativeSeriesRenderer _renderer, uint256 _tokenHash) =
            _getRendererWithParams(creatorContractAddress, tokenId);
        return _renderer.tokenURI(tokenId, _tokenHash);
    }

    function tokenImage(address creatorContractAddress, uint256 tokenId)
        external
        view
        rendererIsSet(creatorContractAddress)
        returns (string memory)
    {
        (IGenerativeSeriesRenderer _renderer, uint256 _tokenHash) =
            _getRendererWithParams(creatorContractAddress, tokenId);
        return _renderer.tokenImage(tokenId, _tokenHash);
    }

    function tokenHTML(address creatorContractAddress, uint256 tokenId)
        external
        view
        rendererIsSet(creatorContractAddress)
        returns (string memory)
    {
        (IGenerativeSeriesRenderer _renderer, uint256 _tokenHash) =
            _getRendererWithParams(creatorContractAddress, tokenId);
        return _renderer.tokenHTML(tokenId, _tokenHash);
    }

    function tokenJSON(address creatorContractAddress, uint256 tokenId)
        external
        view
        rendererIsSet(creatorContractAddress)
        returns (string memory)
    {
        (IGenerativeSeriesRenderer _renderer, uint256 _tokenHash) =
            _getRendererWithParams(creatorContractAddress, tokenId);
        return _renderer.tokenJSON(tokenId, _tokenHash);
    }

    function _getRendererWithParams(address creatorContractAddress, uint256 tokenId)
        internal
        view
        returns (IGenerativeSeriesRenderer, uint256)
    {
        IGenerativeSeriesRenderer _renderer = IGenerativeSeriesRenderer(renderer[creatorContractAddress]);
        uint256 _tokenHash = tokenHash[creatorContractAddress][tokenId];
        return (_renderer, _tokenHash);
    }

    function createSeries(address creatorContractAddress, uint16 _maxSupply, address _renderer)
        external
        creatorAdminRequired(creatorContractAddress)
        seriesNotInitialized(creatorContractAddress)
    {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        maxSupply[creatorContractAddress] = _maxSupply;
        renderer[creatorContractAddress] = _renderer;
    }

    function setRenderer(address creatorContractAddress, address _renderer)
        external
        creatorAdminRequired(creatorContractAddress)
        isNotFrozen(creatorContractAddress)
    {
        renderer[creatorContractAddress] = _renderer;
    }

    function setMinter(address creatorContractAddress, address _minter)
        external
        creatorAdminRequired(creatorContractAddress)
        isNotFrozen(creatorContractAddress)
    {
        minter[creatorContractAddress] = _minter;
    }

    function freeze(address creatorContractAddress)
        external
        creatorAdminRequired(creatorContractAddress)
        isNotFrozen(creatorContractAddress)
    {
        frozen[creatorContractAddress] = true;
    }

    function mintReserve(address creatorContractAddress, address to)
        external
        creatorAdminRequired(creatorContractAddress)
        seriesHasSupplyLeft(creatorContractAddress)
        isNotFrozen(creatorContractAddress)
    {
        _mint(creatorContractAddress, to);
    }

    function mint(address creatorContractAddress, address to)
        external
        onlyMinter(creatorContractAddress)
        seriesHasSupplyLeft(creatorContractAddress)
        isNotFrozen(creatorContractAddress)
    {
        _mint(creatorContractAddress, to);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AdminControl, IERC165) returns (bool) {
        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId || AdminControl.supportsInterface(interfaceId)
            || super.supportsInterface(interfaceId);
    }

    function _mint(address creatorContractAddress, address to) internal {
        unchecked {
            ++currentSupply[creatorContractAddress];
        }
        uint256 tokenId = IERC721CreatorCore(creatorContractAddress).mintExtension(to);
        uint256 _tokenHash = _generateTokenHash(tokenId, to);
        tokenHash[creatorContractAddress][tokenId] = _tokenHash;
    }

    function _generateTokenHash(uint256 _tokenId, address to) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, to, _tokenId)));
    }
}
