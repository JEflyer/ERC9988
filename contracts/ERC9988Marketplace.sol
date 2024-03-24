// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC9988Metadata.sol";

contract ERC9988Marketplace is Ownable {
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 phase;
        uint256 amount;
        uint256 price; // Price in ERC20 tokens
        address currency; // Address of the ERC20 token used for payment
    }

    // Mapping from listing ID to Listing object
    mapping(uint256 => Listing) public listings;
    uint256 private _listingIdCounter;

    // Mapping to keep track of accepted ERC20 tokens for payment
    mapping(address => bool) public acceptedCurrencies;

    IERC9988 public immutable erc9988Contract;

    address winningPot;

    event ListingCreated(
        uint256 indexed listingId, 
        address indexed seller, 
        uint256 indexed tokenId, 
        uint256 phase, 
        uint256 amount, 
        uint256 price, 
        address currency
    );
    event ListingCancelled(uint256 indexed listingId, address indexed seller);
    event Purchase(
        uint256 indexed listingId, 
        address indexed buyer, 
        uint256 indexed tokenId, 
        uint256 phase, 
        uint256 amount, 
        uint256 price, 
        address currency
    );
    event CurrencyAccepted(address currency, bool status);

    constructor(address _erc9988Address, 
        address usdcAddress, 
        address wmaticAddress,
        address winningPotAddress
    ) Ownable(msg.sender) {
        require(_erc9988Address != address(0), "Invalid ERC9988 contract address");
        require(usdcAddress != address(0), "Invalid USDC contract address");
        require(wmaticAddress != address(0), "Invalid WMATIC contract address");
        require(winningPotAddress != address(0), "Invalid Winnig Pot address");

        winningPot = winningPotAddress;

        erc9988Contract = IERC9988(_erc9988Address);
        acceptedCurrencies[usdcAddress] = true;
        acceptedCurrencies[wmaticAddress] = true;
    }

    function addAcceptedCurrency(address currency, bool status) external onlyOwner {
        require(currency != address(0), "Invalid currency address");
        acceptedCurrencies[currency] = status;
        emit CurrencyAccepted(currency, status);
    }

    function createListing(uint256 tokenId, uint256 phase, uint256 amount, uint256 price, address currency) external {
        require(acceptedCurrencies[currency], "Currency not accepted for payments");
        require(erc9988Contract.balanceOfPhase(tokenId, phase, msg.sender) >= amount, "Insufficient balance for this phase");
        require(price > 0, "Price must be greater than zero");

        require(erc9988Contract.transferFrom(msg.sender,address(this),tokenId,phase,amount),"Failed transfer");

        uint256 listingId = _listingIdCounter++;
        listings[listingId] = Listing(msg.sender, tokenId, phase, amount, price, currency);

        emit ListingCreated(listingId, msg.sender, tokenId, phase, amount, price, currency);
    }

    function cancelListing(uint256 listingId) external {
        Listing memory listing = listings[listingId];
        require(listing.seller == msg.sender, "Only the seller can cancel this listing");
        require(erc9988Contract.transferFrom(address(this),msg.sender,listing.tokenId,listing.phase,listing.amount),"Failed transfer");

        delete listings[listingId];
        emit ListingCancelled(listingId, msg.sender);
    }

    function buy(uint256 listingId) external {
        Listing memory listing = listings[listingId];
        require(listing.amount > 0, "Listing does not exist or has been sold");
        require(acceptedCurrencies[listing.currency], "Currency not accepted for payments");

        // Calculate the marketplace fee (2% of the sale price)
        uint256 fee = listing.price * 2 / 100;
        uint256 sellerProceeds = listing.price - fee;

        // Transfer ERC20 tokens from buyer to seller (minus the marketplace fee)
        IERC20 currency = IERC20(listing.currency);
        require(currency.transferFrom(msg.sender, listing.seller, sellerProceeds), "Payment transfer failed");

        // Distribute the fee: 50% to ERC9988 contract, 50% reserved for defractionalizer
        uint256 splitFee = fee / 2;
        require(currency.transferFrom(msg.sender, winningPot, splitFee), "Fee transfer to ERC9988 failed");
        require(currency.transferFrom(msg.sender, owner(), splitFee), "Fee transfer to owner failed");

        // Transfer NFT or token phase from this contract to buyer
        erc9988Contract.transferFrom(address(this), msg.sender, listing.tokenId, listing.phase, listing.amount);

        delete listings[listingId];
        emit Purchase(listingId, msg.sender, listing.tokenId, listing.phase, listing.amount, listing.price, listing.currency);
    }
}
