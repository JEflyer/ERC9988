//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IERC9988Metadata.sol";

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