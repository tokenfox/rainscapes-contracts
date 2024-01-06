// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IGenerativeSeriesExtension} from "./interfaces/IGenerativeSeriesExtension.sol";

contract RainscapesMinter is Ownable {
    struct MintInfo {
        uint256 price;
        uint256 startsAt;
        uint256 publicStartsAt;
        uint256 endsAt;
        uint16 currentSupply;
        uint16 maxSupply;
        address addr;
        bool addrAllowlisted;
        bool addrMinted;
    }

    mapping(address => bool) public allowlisted;
    mapping(address => bool) public minted;
    IGenerativeSeriesExtension public generativeSeriesExtension;
    address public creatorContractAddress;
    uint256 public mintPrice;
    uint256 public mintStartsAt;
    uint256 public mintEndsAt;
    uint256 public minimumMintLength = 1000;

    modifier mintNotScheduled() {
        require(mintStartsAt == 0 && mintEndsAt == 0, "Mint already scheduled");
        _;
    }

    modifier mintIsOpen() {
        require(mintStartsAt <= block.timestamp && block.timestamp < mintEndsAt, "Allowlist mint is not open");
        _;
    }

    modifier publicMintIsOpen() {
        require(publicMintOpensAt() <= block.timestamp && block.timestamp < mintEndsAt, "Public mint is not open");
        _;
    }

    modifier isAllowlisted(address _address) {
        require(allowlisted[_address], "Not allowlisted");
        _;
    }

    modifier hasSentMintPrice() {
        require(msg.value >= mintPrice, "Insuffient payment");
        _;
    }

    modifier hasNotMinted(address _address) {
        require(!minted[_address], "Address has already minted");
        _;
    }

    modifier hasSupplyLeft() {
        require(
            generativeSeriesExtension.currentSupply(creatorContractAddress)
                < generativeSeriesExtension.maxSupply(creatorContractAddress),
            "Supply is full"
        );
        _;
    }

    constructor(address _generativeSeriesExtension, address _creatorContractAddress, uint256 _mintPrice) {
        generativeSeriesExtension = IGenerativeSeriesExtension(_generativeSeriesExtension);
        creatorContractAddress = _creatorContractAddress;
        mintPrice = _mintPrice;
    }

    function scheduleMint(uint256 _mintStartsAt, uint256 _mintEndsAt) public onlyOwner mintNotScheduled {
        require(_mintStartsAt + minimumMintLength < _mintEndsAt, "Invalid mint schedule");

        mintStartsAt = _mintStartsAt;
        mintEndsAt = _mintEndsAt;
    }

    function mintAllowlist(address to)
        public
        payable
        mintIsOpen
        isAllowlisted(to)
        hasNotMinted(to)
        hasSentMintPrice
        hasSupplyLeft
    {
        minted[to] = true;
        generativeSeriesExtension.mint(creatorContractAddress, to);
    }

    function mintPublic(address to) public payable publicMintIsOpen hasNotMinted(to) hasSentMintPrice hasSupplyLeft {
        minted[to] = true;
        generativeSeriesExtension.mint(creatorContractAddress, to);
    }

    function changeAllowlist(address[] memory to, bool _allow) public onlyOwner {
        require(to.length > 0, "Empty allowlist");

        for (uint256 i = 0; i < to.length;) {
            allowlisted[to[i]] = _allow;

            unchecked {
                ++i;
            }
        }
    }

    function publicMintOpensAt() public view returns (uint256) {
        return mintStartsAt + (mintEndsAt - mintStartsAt) / 2;
    }

    function blockTimeStampNow() external view returns (uint256) {
        return block.timestamp;
    }

    function getMintInfo(address addr) external view returns (MintInfo memory) {
        MintInfo memory mintInfo = MintInfo({
            price: mintPrice,
            startsAt: mintStartsAt,
            publicStartsAt: publicMintOpensAt(),
            endsAt: mintEndsAt,
            currentSupply: generativeSeriesExtension.currentSupply(creatorContractAddress),
            maxSupply: generativeSeriesExtension.maxSupply(creatorContractAddress),
            addr: addr,
            addrAllowlisted: allowlisted[addr],
            addrMinted: minted[addr]
        });

        return mintInfo;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }
}
