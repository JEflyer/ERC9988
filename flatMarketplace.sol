// Sources flattened with hardhat v2.22.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File contracts/IERC9988Metadata.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.20;

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


// File contracts/ERC9988Marketplace.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.20;



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
    uint256 private _listingIdCounter = 1;

    // Mapping to keep track of accepted ERC20 tokens for payment
    mapping(address => bool) public acceptedCurrencies;

    IERC9988 public immutable erc9988Contract;

    address winningPot;

    uint256[] public activeListingIds; // Array to store IDs of active listings

    // Mapping from listing ID to its index in the activeListingIds array + 1 (to differentiate index 0)
    mapping(uint256 => uint256) private listingIdToActiveIndex;

    mapping(address => uint256[]) public sellerToListingIds;
    mapping(uint256 => uint256) private listingIdToSellerIndex;
    
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
        require(price > 0, "Price must be greater than zero");
        require(erc9988Contract.balanceOfPhase(tokenId, phase, msg.sender) >= amount, "Insufficient balance for this phase");

        require(erc9988Contract.transferFrom(msg.sender,address(this),tokenId,phase,amount),"Failed transfer");

        uint256 listingId = _listingIdCounter++;
        listings[listingId] = Listing(msg.sender, tokenId, phase, amount, price, currency);


        activeListingIds.push(listingId);
        listingIdToActiveIndex[listingId] = activeListingIds.length; // Index + 1

        sellerToListingIds[msg.sender].push(listingId);

        listingIdToSellerIndex[listingId] = sellerToListingIds[msg.sender].length - 1;

        emit ListingCreated(listingId, msg.sender, tokenId, phase, amount, price, currency);
    }

    function cancelListing(uint256 listingId) external {
        Listing memory listing = listings[listingId];
        require(listing.seller == msg.sender, "Only the seller can cancel this listing");
        require(erc9988Contract.transferFrom(address(this),msg.sender,listing.tokenId,listing.phase,listing.amount),"Failed transfer");

        
        _removeActiveListing(listingId);
        _removeListingFromSeller(listingId);
        delete listings[listingId];
        
        emit ListingCancelled(listingId, msg.sender);
    }

    // New function to get the count of active listings
    function getActiveListingsCount() public view returns (uint256) {
        return activeListingIds.length;
    }

    function _removeActiveListing(uint256 listingId) private {
        uint256 index = listingIdToActiveIndex[listingId];
        require(index > 0, "Listing is not active");
        
        // Adjust index to match array indexing
        index -= 1;
        
        // Move the last element to the deleted spot to maintain array integrity
        uint256 lastListingId = activeListingIds[activeListingIds.length - 1];
        activeListingIds[index] = lastListingId;
        listingIdToActiveIndex[lastListingId] = index + 1;
        
        // Remove the last element
        activeListingIds.pop();
        delete listingIdToActiveIndex[listingId];
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

        _removeActiveListing(listingId);
        _removeListingFromSeller(listingId);
        delete listings[listingId];
        emit Purchase(listingId, msg.sender, listing.tokenId, listing.phase, listing.amount, listing.price, listing.currency);
    }

    function getActiveListingIdAtIndex(uint256 index) public view returns (uint256) {
        require(index < activeListingIds.length, "Index out of bounds");
        return activeListingIds[index];
    }

    function _removeListingFromSeller(uint256 listingId) private {
        address seller = listings[listingId].seller;
        uint256 index = listingIdToSellerIndex[listingId];

        require(sellerToListingIds[seller].length > 0, "No listings for seller");

        uint256 lastListingId = sellerToListingIds[seller][sellerToListingIds[seller].length - 1];

        sellerToListingIds[seller][index] = lastListingId;
        listingIdToSellerIndex[lastListingId] = index;

        sellerToListingIds[seller].pop();
        delete listingIdToSellerIndex[listingId];
    }

    function getActiveListingsForSeller(address seller) public view returns (uint256[] memory) {
        return sellerToListingIds[seller];
    }
}
