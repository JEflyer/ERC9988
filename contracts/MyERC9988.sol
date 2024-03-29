// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./ERC9988.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KingOfFractionalisation is ERC9988 {
    using Strings for uint256;

    // Token URI prefix
    string private _baseTokenURI;
    string private _basePhaseURI;

    IERC20 private usdc;
    IERC20 private wmatic;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_,
        string memory basePhaseURI_, 
        address usdcAddress, 
        address wmaticAddress
    ) ERC9988(name_, symbol_, msg.sender) {
        _baseTokenURI = baseTokenURI_;
        _basePhaseURI = basePhaseURI_;

        usdc = IERC20(usdcAddress);
        wmatic = IERC20(wmaticAddress);
    }

    // Override the tokenURI method to fetch the metadata for a given token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_baseTokenURI));
    }

    // Implement phaseURI to fetch the metadata for a specific phase of a given token
    function phaseURI(uint256 tokenId, uint256 phase) public view override returns (string memory) {
        return string(abi.encodePacked(_basePhaseURI, "/", phase.toString(), ".json"));
    }

    // Public function to mint new tokens; only owner can mint
    function mint(address to, uint256[] memory phaseMultipliers) public onlyOwner {
        require(phaseMultipliers.length > 0,"ERC9988: Must be fractional atleast once");
        _mintNewToken(to, phaseMultipliers);
    }

    // Public function to transition a token from one phase to another
    function transitionPhase(uint256 parentTokenId, uint256 phaseFrom, uint256 phaseTo, uint256 amount) public {
        TransitionPhase(parentTokenId, phaseFrom, phaseTo, msg.sender, amount);
    }

    // Public function to burn tokens in a specific phase
    // Disabled for the King of Fractionalisation game 
    // function burn(uint256 parentTokenId, uint256 phase, uint256 amount) public {
    //     burnPhaseToken(parentTokenId, phase, msg.sender, amount);
    // }

    // Setters for URI prefixes (admin only)
    function setBaseTokenURI(string memory baseTokenURI_) external onlyOwner {
        _baseTokenURI = baseTokenURI_;
    }

    function setBasePhaseURI(string memory basePhaseURI_) external onlyOwner {
        _basePhaseURI = basePhaseURI_;
    }

}
