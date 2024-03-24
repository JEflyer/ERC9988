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


// File @openzeppelin/contracts/utils/math/Math.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}


// File @openzeppelin/contracts/utils/math/SignedMath.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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


// File contracts/ERC9988.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.20;



/// @notice ERC9988
///         A gas-efficient, mixed ERC20 / ERC721 implementation
///         designed primarily for supply chain processes, enabling
///         assets to transition through phases from ERC721 (unique assets) 
///         to ERC20 (fungible assets), and then to another phase of ERC20 tokens.
///         This facilitates the tracking and fractionalization of assets
///         as they move through various stages of the supply chain.
///
///         This experimental standard aims to integrate
///         with pre-existing ERC20 / ERC721 support as smoothly as
///         possible, catering specifically to the nuanced needs of supply chain
///         management and logistics.
///
/// @dev    In order to support the full functionality required by supply chains,
///         where assets undergo multiple phases of breakdown or aggregation,
///         certain supply assumptions are made. It is recommended to ensure
///         decimals are sufficiently large (standard 18 recommended) as ids are
///         effectively encoded in the lowest range of amounts to facilitate these transitions.
///
///         By design, NFTs are spent on ERC20 functions in a FILO queue to mimic
///         real-world logistics operations, emphasizing the transition from unique
///         assets to divisible ones and then possibly to other forms of divisible assets
///         reflecting different stages of the supply chain.
///

abstract contract ERC9988 is Ownable, IERC9988 {

    // Metadata
    /// @dev Token name
    string public name;

    /// @dev Token symbol
    string public symbol;

    /// @dev Decimals for fractional representation
    uint8 public immutable decimals;

    /// @dev Current mint counter, monotonically increasing to ensure accurate ownership
    uint256 public minted;

    //PhaseID list
    //0 = NFT
    //1 = Phase 1 Token
    //2 = Phase 2 Token
    //3 = Phase 3 Token
    //4 = Phase 4 Token
    //5 = Phase 5 Token

    // Mappings
    /// @dev Array of tokenIDs that a owner owns some of
    mapping(address => uint256[]) internal _owned;

    /// @dev Stores the current address that owns phase 0 of a token ID
    mapping(uint256 => address) private phase0Owners;

    /// @dev Array of phases in a tokenIDs that a owner owns some of
    /// address owner => uint256 tokenID => uint256[] phases
    mapping(address => mapping(uint256 => uint256[])) internal _phasesOwned;

    //Mapping for keeping track of the total amount of tokens in each phase of a broken token
    //ERC721 uint256 TokenID => uint256 phaseID => uint256 amount
    mapping(uint256 => mapping(uint256 => uint256)) internal totalSupplys;

    //Mapping for keeping track of the total amount of tokens a wallet owns for each phase of a broken token
    //ERC721 uint256 TokenID => uint256 phaseID => address owner => uint256 amount
    mapping(uint256 => mapping(uint256 => mapping(address=> uint256))) internal balances;

//     // Mapping from token ID to phase to owner to spender addresses for allowances
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(address => uint256)))) public phaseAllowances;

    // Mapping for tracking approvals of a onwers => NFTs(phase 0) tokenID => approved address 
    mapping(address => mapping(uint256 => address)) private approvals;

    mapping(address => address) private approvalsForAll;

    mapping(uint256 => address) private isApproved;

    mapping(uint256 => uint256[]) public tokenPhaseMultipliers;


    // Events
    event ERC9988Transfer(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 phase,
        uint256 amount
    );
    event ERC721Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event TransferPhase(
        uint256 indexed parentTokenId, 
        uint256 indexed phaseFrom, 
        uint256 indexed phaseTo, 
        address to, 
        uint256 amount
    );
    event BurnPhase(
        uint256 indexed parentTokenId, 
        uint256 indexed phase, 
        address indexed from, 
        uint256 amount
    );
    event MintingPhase(
        uint256 indexed tokenID, 
        uint256 indexed phase, 
        address indexed to, 
        uint256 amount
    );

    // Errors
    error NotFound();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error UnsafeRecipient();
    error Unauthorized();
    error ZeroAddress();
    error NonExistentToken();
    error InvalidPhase();

    // Constructor
    constructor(
        string memory _name,
        string memory _symbol,
        address _owner
    ) Ownable(_owner) {
        name = _name;
        symbol = _symbol;
        decimals = 0;
    }


    ////////////////   VIEW FUNCTIONS ///////////////////////////////

    /////ERC9988//////////

    // Get the balance of an address for a specific token phase
    function balanceOfPhase(uint256 parentTokenId, uint256 phase, address owner) public view returns (uint256) {
        return balances[parentTokenId][phase][owner];
    }

    function tokensOwned(address owner) external view returns (uint256[] memory){
        return _owned[owner];
    }

    function phasesOwnedOfToken(address owner, uint256 tokenID) external view returns(uint256[] memory){
        return _phasesOwned[owner][tokenID];
    }

    function totalSupplyOfTokenPhase(uint256 tokenID, uint256 phase) external view returns(uint256){
        return totalSupplys[tokenID][phase];
    }

    function phaseURI(uint256 id,uint256 phase) public view virtual returns (string memory);
    /////ERC9988//////////
    
    /////ERC721//////////

    function balanceOf(address owner) public view returns (uint256 balance) {
        if(owner == address(0)) revert ZeroAddress();

        uint256 totalBalance = 0;
        uint256[] memory ownedTokens = _owned[owner]; // Retrieve the list of tokens owned by 'owner'

        for (uint256 i = 0; i < ownedTokens.length; i++) {
            // For each token, check if the owner has a balance in phase 0
            if (balances[ownedTokens[i]][0][owner] > 0) {
                // Increment the total balance for each token found in phase 0
                totalBalance += 1;
            }
        }

        return totalBalance;
    }

    function ownerOf(uint256 tokenId) public view returns (address owner) {
        owner = phase0Owners[tokenId];
        if(owner == address(0)) revert NonExistentToken();
        return owner;
    }
    
    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator){
        return isApproved[tokenId];
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool){
        return approvalsForAll[owner] == operator;
    }


    function tokenURI(uint256 id) public view virtual returns (string memory);
    
    /////ERC721//////////
    
    /////ERC165//////////

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC9988).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId;
    }

    function getInterfaceID() external view returns(bytes4){
        return type(IERC9988).interfaceId;
    }
    /////ERC165//////////

    ////////////////   VIEW FUNCTIONS ///////////////////////////////


    ////////////////   PUBLIC FUNCTIONS ///////////////////////////////

    /////ERC9988//////////

    function approvePhaseToken(uint256 tokenId, uint256 phase, address spender, uint256 amount) public {
        phaseAllowances[tokenId][phase][msg.sender][spender] = amount;
    }

    function setApprovalForAll(address operator, bool approved) public {
        if (approved){
            approvalsForAll[msg.sender] = operator;
        }else{
            delete approvalsForAll[msg.sender];
        }
    }

    /// @notice Transfers tokens from one account to another, either for a specific phase or the original NFT.
    /// @dev Can be used for both ERC20 phase tokens and the original ERC721 NFT.
    /// @param from The address to transfer tokens from.
    /// @param to The address to transfer tokens to.
    /// @param tokenId The ID of the token to transfer.
    /// @param phase The phase of the token to transfer, with 0 indicating the original NFT.
    /// @param amount The amount of tokens to transfer, applicable only for ERC20 phase tokens.
    function transferFrom(address from, address to, uint256 tokenId, uint256 phase, uint256 amount) public override returns(bool){
        if(phase > tokenPhaseMultipliers[tokenId].length) revert InvalidPhase();

        if(from != msg.sender){
            if(phase == 0){
                require(
                    approvals[from][tokenId] == msg.sender
                    ||
                    approvalsForAll[from] == msg.sender,
                    "ERC9988: NOT APPROVED FOR TRANSFER"      
                );
            }else{
                require(
                    phaseAllowances[tokenId][phase][from][msg.sender] >= amount,
                    "ERC9988: NOT APPROVED FOR TRANSFER"
                );
            }
        }
        
        if (phase == 0) {
            // Handle ERC721 NFT transfer
            require(balances[tokenId][phase][from] >= amount, "Insufficient balance");
            require(to != address(0), "Invalid recipient address");
            
            balances[tokenId][phase][from] -= amount;
            balances[tokenId][phase][to] += amount;

            phase0Owners[tokenId] = to;
            if(from != msg.sender){
                _removeApproval(tokenId,from);
            }
            
            emit Transfer(from, to, tokenId);
        } else {
            // Handle ERC20 phase token transfer
            require(balances[tokenId][phase][from] >= amount, "Insufficient balance");
            require(to != address(0), "Invalid recipient address");

            balances[tokenId][phase][from] -= amount;
            balances[tokenId][phase][to] += amount;

            if(from != msg.sender){
                phaseAllowances[tokenId][phase][from][msg.sender] -= amount;
            }

            emit ERC9988Transfer(from, to, tokenId, phase, amount);
        }

        // Update ownership mapping for the recipient
        if (!_isTokenOwnedBy(to, tokenId)) {
            _owned[to].push(tokenId);
        }

        // Update phase ownership for the recipient
        if (!_isPhaseOwnedBy(to, tokenId, phase)) {
            _phasesOwned[to][tokenId].push(phase);
        }

        // After transferring, check if 'from' still owns any of this phase, if not, remove the phase
        // and if they don't own any phase of the token, remove the token ID from their `_owned` list.
        _updateOwnershipAfterTransfer(from, tokenId, phase);
        
        return true;
    }

    function batchTransferFrom(address from, address to, uint256[] memory tokenIds, uint256[] memory phases, uint256[] memory amounts) public {
        require(tokenIds.length == phases.length && phases.length == amounts.length, "ERC9988: Arrays must be of the same length");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            transferFrom(from, to, tokenIds[i], phases[i], amounts[i]);
        }
    }


    /////ERC9988//////////

    /////ERC721//////////
    function transferFrom(address from, address to, uint256 tokenId) public  {
        require(phase0Owners[tokenId] == from, "ERC9988: transfer of token that is not own");
        require(to != address(0), "ERC9988: transfer to the zero address");

        // Ensure the token is in phase 0
        require(_isPhaseOwnedBy(from, tokenId, 0), "ERC9988: Only phase 0 tokens can be transferred");

        // Clear approval from the previous owner
        _removeApproval(tokenId,from);

        _transfer(from, to, tokenId);
    }

    

    function safeTransferFrom(address from, address to, uint256 tokenId) public  {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public  {
        transferFrom(from, to, tokenId); // Perform the transfer first

        require(_checkOnERC721Received(from, to, tokenId, data), "ERC9988: transfer to non ERC721Receiver implementer");
    }


    /// @notice Approves another address to transfer the given token ID
    /// @dev The caller must own the token or be an approved operator
    /// @param to The address to be approved
    /// @param tokenId The token ID to be approved
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        
        // Require that the person approving is the owner of the token or 
        // an approved operator for the owner.
        require(to != owner, "ERC9988: approval to current owner");
        require(msg.sender == owner, 
                "ERC9988: approve caller is not owner");

        // Update the approval mappings
        approvals[owner][tokenId] = to;
        isApproved[tokenId] = to;

        // Emit the approval event
        emit Approval(owner, to, tokenId);
    }

    /////ERC721//////////
    
    ////////////////   PUBLIC FUNCTIONS ///////////////////////////////

    ////////////////   PRIVATE FUNCTIONS ///////////////////////////////

    /////ERC9988//////////
    function _isTokenOwnedBy(address owner, uint256 tokenId) private view returns (bool) {
        uint256[] storage ownedTokens = _owned[owner];
        for (uint256 i = 0; i < ownedTokens.length; i++) {
            if (ownedTokens[i] == tokenId) {
                return true;
            }
        }
        return false;
    }

    function _isPhaseOwnedBy(address owner, uint256 tokenId, uint256 phase) private view returns (bool) {
        uint256[] storage ownedPhases = _phasesOwned[owner][tokenId];
        for (uint256 i = 0; i < ownedPhases.length; i++) {
            if (ownedPhases[i] == phase) {
                return true;
            }
        }
        return false;
    }

    function _updateOwnershipAfterTransfer(address from, uint256 tokenId, uint256 phase) private {
        // Remove phase from sender if they no longer own any of this phase
        _removePhaseOwnership(from, tokenId, phase);


        // If 'from' no longer owns any phase of the token, also remove the token ID from `_owned`
        if (_shouldRemoveTokenID(from, tokenId)) {
            _removeTokenIDFromOwned(from, tokenId);
        }
    }

    function _shouldRemoveTokenID(address owner, uint256 tokenId) private view returns (bool) {
        // Assuming there are 6 phases in total (0-5), as mentioned in your comment.
        for (uint256 phase = 0; phase <= 5; phase++) {
            if (balances[tokenId][phase][owner] > 0) {
                // Owner still owns a part of this token in some phase.
                return false;
            }
        }
        // Owner does not own any part of the token in any phase.
        return true;
    }

    function _removeTokenIDFromOwned(address owner, uint256 tokenId) private {
        uint256 length = _owned[owner].length;
        for (uint256 i = 0; i < length; i++) {
            if (_owned[owner][i] == tokenId) {
                // Found the token ID, remove it by swapping with the last element and then shortening the array.
                _owned[owner][i] = _owned[owner][length - 1];
                _owned[owner].pop();
                break; // Exit the loop once the token ID is found and removed.
            }
        }
    }

    function _removePhaseOwnership(address owner, uint256 tokenId, uint256 phase) private {
        if (balances[tokenId][phase][owner] == 0) {
            // Find the phase in the owner's list and remove it
            uint256[] storage ownedPhases = _phasesOwned[owner][tokenId];
            uint256 length = ownedPhases.length;
            for (uint256 i = 0; i < length; i++) {
                if (ownedPhases[i] == phase) {
                    // Found the phase, remove it by swapping with the last element and then popping
                    ownedPhases[i] = ownedPhases[length - 1];
                    ownedPhases.pop();
                    break;
                }
            }
            
            // After removing the phase, check if the owner no longer owns any phases of the token
            if (ownedPhases.length == 0) {
                _removeTokenIDFromOwned(owner, tokenId);
            }
        }
    }

    function _mintNewToken(address to,uint256[] memory phaseMultipliers) internal {
        require(phaseMultipliers.length <= 5 && phaseMultipliers.length > 0,"ERROR: INVALID NUMBER OF PHASES");

        uint256 tokenID = ++minted;

        totalSupplys[tokenID][0] += 1;
        balances[tokenID][0][to] += 1;

        _owned[to].push(tokenID);
        _phasesOwned[to][tokenID].push(0);
        phase0Owners[tokenID] = to;

        tokenPhaseMultipliers[tokenID] = phaseMultipliers;

        emit MintingPhase(tokenID, 0, to, 1);
        emit Transfer(address(0), to, tokenID);
    }
    
    /////ERC9988//////////

    /////ERC721///////////

    function _transfer(address from, address to, uint256 tokenId) private {
        // Transfer ownership in the phase0Owners mapping
        phase0Owners[tokenId] = to;

        // Update the internal mappings to reflect the new ownership
        _removeTokenIDFromOwned(from, tokenId);
        _owned[to].push(tokenId);
        _phasesOwned[to][tokenId].push(0);
        removePhaseZero(tokenId, from); // Remove phase 0 from the sender

        emit Transfer(from, to, tokenId);
    }

    function removePhaseZero(uint256 tokenId, address owner) private {
        uint256 length = _phasesOwned[owner][tokenId].length;
        uint256[] memory tempArray = new uint256[](length);
        uint256 count = 0; // Keep track of the count of non-zero phases

        // Iterate over all phases, copying non-zero phases to the tempArray
        for (uint256 i = 0; i < length; i++) {
            if (_phasesOwned[owner][tokenId][i] != 0) {
                tempArray[count] = _phasesOwned[owner][tokenId][i];
                count++;
            }
        }

        // Create a new array with the size of count
        uint256[] memory newArray = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            newArray[i] = tempArray[i];
        }

        // Replace the original phases array with the newArray
        _phasesOwned[owner][tokenId] = newArray;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC9988: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function isContract(address account) private view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the constructor execution.
        
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    /////ERC721///////////

    ////////////////   PRIVATE FUNCTIONS ///////////////////////////////
    

    ////////////////   INTERNAL FUNCTIONS ///////////////////////////////


    /////ERC9988//////////

    function TransitionPhase(uint256 parentTokenId,uint256 phaseFrom, uint256 phaseTo, address to, uint256 amount) internal {
        uint256 numOfPhases = tokenPhaseMultipliers[parentTokenId].length;
        
        require(phaseTo != phaseFrom, "You can not transition to the same phase");
        require(phaseTo <= numOfPhases && phaseFrom <= numOfPhases, "Invalid phase");

        require(balances[parentTokenId][phaseFrom][msg.sender] >= amount, "Insufficient tokens in previous phase");

        uint256[] memory multipliers = tokenPhaseMultipliers[parentTokenId];

        //TODO
        uint256 amountMinted;
        uint256 amountBurned;

        if(phaseFrom < phaseTo){
            //Scaling to the next phase
            amountMinted = amount * multipliers[phaseFrom];
            amountBurned = amount;
        }else {
            //Scaling to the previous phase
            //Check that the amount being transitioned is enough
            require(amount <= balances[parentTokenId][phaseFrom][msg.sender],"ERROR: NOT ENOUGH BALANCE");
            require(amount >= multipliers[phaseTo],"ERROR: NOT BURNING ENOUGH TOKENS TO PHASE UP");
            amountMinted = amount / multipliers[phaseTo];
            uint256 amountNotBurned = amount - amountMinted * multipliers[phaseTo];
            amountBurned = amount - amountNotBurned;
        }


        // Decrease the supply from the previous phase
        totalSupplys[parentTokenId][phaseFrom] -= amountBurned;
        balances[parentTokenId][phaseFrom][msg.sender] -= amountBurned;


        // Update total supplies and balances for the new phase
        totalSupplys[parentTokenId][phaseTo] += amountMinted;
        balances[parentTokenId][phaseTo][to] += amountMinted;

        // If transitioning from Phase 0 to another phase, update phase0Owners to remove ownership
        if (phaseFrom == 0) {
            delete phase0Owners[parentTokenId];
            emit Transfer(msg.sender, address(0), parentTokenId);
        }
        
        // If transitioning into Phase 0 from another phase, update phase0Owners to reflect new ownership
        if (phaseTo == 0) {
            phase0Owners[parentTokenId] = to;
            emit Transfer(address(0),msg.sender, parentTokenId);
        }

        // Update _phasesOwned mapping for receiver
        if (!_isPhaseOwnedBy(to, parentTokenId, phaseTo)) {
            _phasesOwned[to][parentTokenId].push(phaseTo);
        }

        // Possibly update _phasesOwned mapping for sender
        if (_shouldRemoveTokenID(msg.sender, parentTokenId)) {
            _removeTokenIDFromOwned(msg.sender, parentTokenId);
        }

        _removePhaseOwnership(msg.sender, parentTokenId, phaseFrom);
        
        emit TransferPhase(parentTokenId, phaseFrom, phaseTo, to, amount);
    }

    // Example Burn Function for a Specific Phase
    function burnPhaseToken(uint256 parentTokenId, uint256 phase, address from, uint256 amount) internal {
        require(balances[parentTokenId][phase][from] >= amount, "Insufficient balance");
        
        // Update total supplies and balances
        totalSupplys[parentTokenId][phase] -= amount;
        balances[parentTokenId][phase][from] -= amount;

        // If burning Phase 0, delete phase0Owners to remove ownership for this tokenID
        if (phase == 0) {
            delete phase0Owners[parentTokenId];
        }
        
        
        // Possibly update _phasesOwned mapping for the sender
        if (_shouldRemoveTokenID(from, parentTokenId)) {
            _removeTokenIDFromOwned(from, parentTokenId);
        }

        _removePhaseOwnership(from, parentTokenId, phase);
        
        emit BurnPhase(parentTokenId, phase, from, amount);
    }

    function _setNameSymbol(
        string memory _name,
        string memory _symbol
    ) internal {
        name = _name;
        symbol = _symbol;
    }

    
    function _removeApproval(uint256 tokenId, address from) internal {
        delete approvals[from][tokenId];
        delete isApproved[tokenId];

        emit Approval(ownerOf(tokenId), address(0), tokenId);
    }
    /////ERC9988//////////
    

    ////////////////   INTERNAL FUNCTIONS ///////////////////////////////



    

    


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


// File contracts/MyERC9988.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.20;



contract MySupplyChainToken is ERC9988 {
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
        return string(abi.encodePacked(_baseTokenURI, "/", tokenId.toString()));
    }

    // Implement phaseURI to fetch the metadata for a specific phase of a given token
    function phaseURI(uint256 tokenId, uint256 phase) public view override returns (string memory) {
        return string(abi.encodePacked(_basePhaseURI, "/", tokenId.toString(), "/", phase.toString()));
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
