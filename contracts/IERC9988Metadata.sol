//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IERC9988 is IERC721Metadata  {
    
    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external returns(uint8);

    function minted() external returns(uint256);

    function tokensOwned(address) external view returns (uint256[] memory);

    function phasesOwnedOfToken(address, uint256) external view returns(uint256[] memory);

    function totalSupplyOfTokenPhase(uint256,uint256) external view returns(uint256);

    function balanceOfPhase(uint256, uint256 phase, address owner) external view returns (uint256);

    function phaseAllowances(uint256,uint256,address,address) external view returns(uint256);

    function approvePhaseToken(uint256 tokenId, uint256 phase, address spender, uint256 amount) external;

    function transferFrom(address from, address to, uint256 tokenId, uint256 phase, uint256 amount) external returns(bool);
    
    function tokenURI(uint256 id) external view  returns (string memory);

    function batchTransferFrom(address from, address to, uint256[] memory tokenIds, uint256[] memory phases, uint256[] memory amounts) external;
}