const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("ERC9988", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC9988Setup() {

    // Contracts are deployed using the first signer/account by default
    const [owner, account1, account2] = await ethers.getSigners();

    const mUSDCFactory = await ethers.getContractFactory("TestToken");
    const mUSDC = await mUSDCFactory.deploy();

    const mWMATICFactory = await ethers.getContractFactory("TestToken");
    const mWMATIC = await mWMATICFactory.deploy();

    const ERC9988Factory = await ethers.getContractFactory("MySupplyChainToken")
    const ERC9988 = await ERC9988Factory.deploy(
      "King of Fractionalisation",
      "KoF",
      "This is a baseTokenURI",
      "This is a basePhaseURI",
      mUSDC.target,
      mWMATIC.target
    )

    const marketFactory = await ethers.getContractFactory("ERC9988Marketplace")
    const marketplace = await marketFactory.deploy(
      ERC9988.target,
      mUSDC.target,
      mWMATIC.target
    )

    return { owner, account1, account2, mUSDC, mWMATIC, ERC9988, marketplace };
  }

  async function deployFixture() {
    // Assume deployOneYearLockFixture is already defined in your tests
    return await loadFixture(deployERC9988Setup);
  }

  describe("Minting", function () {
    it("Allows the owner to mint a new token successfully", async function () {
      const { owner, ERC9988 } = await deployFixture();
      const phaseMultipliers = [2, 3]; // Example phase multipliers
      await expect(ERC9988.connect(owner).mint(owner.address, phaseMultipliers))
        .to.emit(ERC9988, "MintingPhase")
        .withArgs(1, 0, owner.address, 1); // Assuming the first token ID is 1, and phase is 0 with amount 1
    });

    it("Emits a MintingPhase event when a new token is minted", async function () {
      const { owner, ERC9988 } = await deployFixture();
      const phaseMultipliers = [2]; // Example phase multipliers for simplicity
      await expect(ERC9988.connect(owner).mint(owner.address, phaseMultipliers))
        .to.emit(ERC9988, "MintingPhase")
        .withArgs(1, 0, owner.address, 1); // The expected event and args
    });

    it("Prevents non-owners from minting new tokens", async function () {
      const { account1, ERC9988 } = await deployFixture();
      const phaseMultipliers = [2, 3];
      // Attempt to mint by a non-owner should be reverted
      await expect(ERC9988.connect(account1).mint(account1.address, phaseMultipliers))
        .to.be.revertedWithCustomError(ERC9988,"OwnableUnauthorizedAccount(address)");
    });
  });

  describe("Phase Transition", function () {
    it("Allows a valid phase transition", async function () {
      const { owner, ERC9988 } = await deployFixture();
      const phaseMultipliers = [2, 3];
      await ERC9988.connect(owner).mint(owner.address, phaseMultipliers);

      // Perform a valid phase transition
      await expect(ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)) // Assuming the transition is valid
        .to.emit(ERC9988, "TransferPhase")
        .withArgs(1, 0, 1, owner.address, 1); // Check for correct event emission
      
      // Verify phase transition was successful
      const balance = await ERC9988.balanceOfPhase(1, 1, owner.address);
      expect(balance).to.equal(2); // Assuming multiplier effect
    });

    it("Emits a TransferPhase event on successful transition", async function () {
      const { owner, ERC9988 } = await deployFixture();
      await ERC9988.connect(owner).mint(owner.address, [2]);

      // Check for the TransferPhase event on a valid phase transition
      await expect(ERC9988.connect(owner).transitionPhase(1, 0, 1, 1))
        .to.emit(ERC9988, "TransferPhase")
        .withArgs(1, 0, 1, owner.address, 1); // Expected args including the amount after phase transition
    });

    it("Fails to transition to an invalid phase", async function () {
      const { owner, ERC9988 } = await deployFixture();
      await ERC9988.connect(owner).mint(owner.address, [2]);

      // Attempt to transition to a non-existent phase
      await expect(ERC9988.connect(owner).transitionPhase(1, 0, 99, 1))
        .to.be.revertedWith("Invalid phase"); // Adjust the error message to match your contract's logic
    });

    it("Fails to transition with insufficient balance", async function () {
      const { owner, ERC9988 } = await deployFixture();
      await ERC9988.connect(owner).mint(owner.address, [2]);

      // Attempt to transition more tokens than owned in the phaseFrom
      await expect(ERC9988.connect(owner).transitionPhase(1, 0, 1, 100)) // Assuming an excessive amount
        .to.be.revertedWith("Insufficient tokens in previous phase"); // Adjust the error message as necessary
    });
  });

  describe("URI Generation", function () {
    it("Returns the correct Token URI for a given token ID", async function () {
      const { ERC9988 } = await deployFixture();
      const tokenId = 1; // Example token ID, adjust according to your contract's minting logic
      const expectedTokenURI = "This is a baseTokenURI/1"; // Expected URI, adjust based on your contract logic
      
      // Assuming the minting has already occurred, and token ID 1 exists
      const actualTokenURI = await ERC9988.tokenURI(tokenId);

      expect(actualTokenURI).to.equal(expectedTokenURI);
    });

    it("Returns the correct Phase URI for a given token ID and phase", async function () {
      const { ERC9988 } = await deployFixture();
      const tokenId = 1; // Example token ID, adjust according to your contract's minting logic
      const phase = 2; // Example phase number
      const expectedPhaseURI = "This is a basePhaseURI/1/2"; // Expected URI, adjust based on your contract logic

      // Assuming the token ID 1 exists and has phase data available
      const actualPhaseURI = await ERC9988.phaseURI(tokenId, phase);

      expect(actualPhaseURI).to.equal(expectedPhaseURI);
    });
  });

  describe("Supports Interface", function () {
    it("Correctly reports support for expected interfaces", async function () {
      const { ERC9988 } = await deployFixture();
  
      // ERC721 interface ID
      const ERC721InterfaceID = "0x80ac58cd";
      // ERC9988 interface ID (assuming custom function signatures to calculate ID)
      const ERC9988InterfaceID = await ERC9988.getInterfaceID(); 
      // ERC721Metadata interface ID
      const ERC721MetadataInterfaceID = "0x5b5e139f"; 
  
      // Check for ERC721 support
      expect(await ERC9988.supportsInterface(ERC721InterfaceID)).to.be.true;
      // Check for ERC9988 support
      expect(await ERC9988.supportsInterface(ERC9988InterfaceID)).to.be.true;
      // Check for ERC721Metadata support
      expect(await ERC9988.supportsInterface(ERC721MetadataInterfaceID)).to.be.true;
    });
  });

  describe("Recreating NFT from Fractional Tokens", function() {
    it("Should recreate the original NFT from its fractional tokens", async function() {
      const { ERC9988, owner, account1 } = await deployFixture();
  
      // Step 1: Mint the original NFT
      await ERC9988.connect(owner).mint(owner.address, [2, 2]); // Assuming 2 is the multiplier for phase 1
  
      // Step 2: Break down the NFT into fractional tokens
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1); // TokenID 1, phaseFrom 0, phaseTo 1, amount 1
  
      // Verify the TransferPhase event emission
      await expect(ERC9988.connect(owner).transitionPhase(1, 1, 0, 2))
        .to.emit(ERC9988, 'TransferPhase')
        .withArgs(1, 1, 0, owner.address, 2);

      // Verify the owner of the recreated NFT
      expect(await ERC9988.ownerOf(1)).to.equal(owner.address);
  
      // Verify original NFT is recreated correctly without remaining fractional tokens
      expect(await ERC9988.balanceOfPhase(1, 0, owner.address)).to.equal(1);
      expect(await ERC9988.balanceOfPhase(1, 1, owner.address)).to.equal(0);
    });
  });

  describe("Defractionalizing NFT to FT", function() {
    it("Should break down an NFT into fractional tokens correctly and emit events", async function() {
      const { ERC9988, owner, account1 } = await deployFixture();
  
      // Mint an NFT to account1
      await ERC9988.connect(owner).mint(owner.address, [4]); // TokenID increments to 1, multiplier for phase 1 is 4
  
      // Verify the TransferPhase event
      await expect(ERC9988.connect(owner).transitionPhase(1, 0, 1, 1))
        .to.emit(ERC9988, 'TransferPhase')
        .withArgs(1, 0, 1, owner.address, 1); // Note: The amount might need to be adjusted based on your contract's logic
  
      // Verify FTs are correctly allocated
      expect(await ERC9988.balanceOfPhase(1, 1, owner.address)).to.equal(4);
  
      
    });
  });

  describe("Transferring tokens",() => {
    it("Transfers an NFT from one account to another and verifies ownership change", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
      
      const phaseMultipliers = [2]; // Assuming simple fractional setup for demonstration
      await ERC9988.connect(owner).mint(owner.address, phaseMultipliers);
  
      // Transfer the NFT from `owner` to `recipient`
      await expect(ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1))
        .to.emit(ERC9988, 'Transfer')
        .withArgs(owner.address, account1.address, 1);
  
      // Verify ownership change
      expect(await ERC9988.ownerOf(1)).to.equal(account1.address);
    });

    it("Fractionalizes an NFT into smaller tokens and transfers a fraction to another account", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
    
      // Minting a new NFT to owner
      const phaseMultipliers = [2, 3]; // Example multipliers for fractional phases
      await ERC9988.connect(owner).mint(owner.address, phaseMultipliers);
    
      // Fractionalize the NFT: Transitioning from phase 0 (NFT) to phase 1 (fractional tokens)
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1);
    
      // Check initial fractional token balance for owner
      const ownerInitialBalance = await ERC9988.balanceOfPhase(1, 1, owner.address);
      expect(ownerInitialBalance).to.equal(2); // Owner should have 2 fractional tokens from the transition
    
      // Transfer a fraction of the NFT (1 fractional token) from owner to recipient
      await expect(ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1, 1, 1))
        .to.emit(ERC9988, "ERC9988Transfer") // Assuming your contract emits this event on fractional token transfers
        .withArgs(owner.address, account1.address, 1, 1, 1);
    
      // Verify the balances after the transfer
      const ownerFinalBalance = await ERC9988.balanceOfPhase(1, 1, owner.address);
      expect(ownerFinalBalance).to.equal(1); // Owner's balance should decrease by 1
    
      const recipientBalance = await ERC9988.balanceOfPhase(1, 1, account1.address);
      expect(recipientBalance).to.equal(1); // Recipient should receive 1 fractional token
    });

    it("Combines fractional tokens back into the original NFT and transfers it", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
    
      // Mint and fractionalize the NFT
      const phaseMultipliers = [2]; // Assuming a simple 2x multiplier for simplification
      await ERC9988.connect(owner).mint(owner.address, phaseMultipliers);
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1);
    
      // Defractionalize the fractional tokens back into the NFT
      await ERC9988.connect(owner).transitionPhase(1, 1, 0, 2); // Assuming the full amount needed for defractionalization
    
      // Transfer the reconstituted NFT to another account
      await expect(ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1, 0, 1))
        .to.emit(ERC9988, "Transfer")
        .withArgs(owner.address, account1.address, 1);
    
      // Verify the ownership of the reconstituted NFT
      expect(await ERC9988.ownerOf(1)).to.equal(account1.address);
    
      // Verify no fractional tokens remain with the original owner
      const ownerFractionalBalance = await ERC9988.balanceOfPhase(1, 1, owner.address);
      expect(ownerFractionalBalance).to.equal(0);
    });

    it("Executes a batch transfer of multiple fractional tokens from different phases between accounts", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
    
      // Mint multiple NFTs and fractionalize them into different phases
      await ERC9988.connect(owner).mint(owner.address, [2]);
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1);
    
      await ERC9988.connect(owner).mint(owner.address, [3]);
      await ERC9988.connect(owner).transitionPhase(2, 0, 1, 1);
    
      // Prepare data for batch transfer
      const tokenIds = [1, 2];
      const phases = [1, 1];
      const amounts = [2, 3]; // Assuming these are the amounts available for transfer
    
      // Execute batch transfer
      await expect(ERC9988.connect(owner).batchTransferFrom(owner.address, account1.address, tokenIds, phases, amounts))
        .to.emit(ERC9988, "ERC9988Transfer") // This is a placeholder, your contract might emit different or multiple events
        .withArgs(owner.address, account1.address, tokenIds[0], phases[0], amounts[0]) // This might need to be adjusted based on your event structure
        .and.to.emit(ERC9988, "ERC9988Transfer")
        .withArgs(owner.address, account1.address, tokenIds[1], phases[1], amounts[1]);
    
      // Verify balances after the batch transfer
      for (let i = 0; i < tokenIds.length; i++) {
        const senderBalance = await ERC9988.balanceOfPhase(tokenIds[i], phases[i], owner.address);
        expect(senderBalance).to.equal(0); // Assuming all were transferred
        
        const recipientBalance = await ERC9988.balanceOfPhase(tokenIds[i], phases[i], account1.address);
        expect(recipientBalance).to.equal(amounts[i]);
      }
    });
  })

  describe("Transfer Restrictions and Safety Checks", function () {

    it("Reverts when attempting to transfer more fractional tokens than owned", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
  
      // Minting and fractionalizing as setup
      await ERC9988.connect(owner).mint(owner.address, [2]); // Assume this creates 2 fractional tokens
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1); // Fractionalize the NFT
  
      // Attempt to transfer more fractional tokens than owned
      await expect(ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1, 1, 3)) // Attempting to transfer 3 tokens when only 2 exist
        .to.be.revertedWith("Insufficient balance"); 
    });
  
    it("Reverts when attempting to transfer to the zero address", async function () {
      const { ERC9988, owner } = await deployFixture();
  
      // Minting and fractionalizing as setup
      await ERC9988.connect(owner).mint(owner.address, [2]);
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1); // Fractionalize the NFT
  
      // Attempt to transfer fractional tokens to the zero address
      await expect(ERC9988.connect(owner).transferFrom(owner.address, "0x0000000000000000000000000000000000000000", 1, 1, 1))
        .to.be.revertedWith("Invalid recipient address"); 
    });
  
    it("Reverts when attempting to transfer an NFT to the zero address", async function () {
      const { ERC9988, owner } = await deployFixture();
  
      // Minting an NFT as setup
      await ERC9988.connect(owner).mint(owner.address, [2]);
  
      // Attempt to transfer NFT to the zero address
      await expect(ERC9988.connect(owner).transferFrom(owner.address, "0x0000000000000000000000000000000000000000", 1, 0, 1))
        .to.be.revertedWith("Invalid recipient address"); 
    });
  
    it("Reverts when a non-owner attempts to transfer an NFT", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
  
      // Minting an NFT to the owner as setup
      await ERC9988.connect(owner).mint(owner.address, [2]);
  
      // Attempt to transfer NFT by a non-owner
      await expect(ERC9988.connect(account1).transferFrom(owner.address, account1.address, 1, 0, 1))
        .to.be.revertedWith("ERC9988: NOT APPROVED FOR TRANSFER"); 
    });
  
    it("Reverts when attempting to transfer fractional tokens without proper approval", async function () {
      const { ERC9988, owner, account1 } = await deployFixture();
  
      // Minting and fractionalizing as setup
      await ERC9988.connect(owner).mint(owner.address, [2]);
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1); // Fractionalize the NFT
  
      // Attempt to transfer fractional tokens by an unauthorized account
      await expect(ERC9988.connect(account1).transferFrom(owner.address, account1.address, 1, 1, 1))
        .to.be.revertedWith("ERC9988: NOT APPROVED FOR TRANSFER"); 
    });
  });
  
  describe("Interface compliance & Event checks",() => {
    it("Verifies ERC721 compliance in NFT transfers", async function() {
      const { ERC9988, owner, account1 } = await deployFixture();
      await ERC9988.connect(owner).mint(owner.address, [2]); // Mint a new NFT with an example phase multiplier
      
      // Transfer the NFT from owner to account1 and verify ERC721 Transfer event
      await expect(ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1)) // Assuming the minted token ID is 1
        .to.emit(ERC9988, 'Transfer')
        .withArgs(owner.address, account1.address, 1);
      
      // Verify ownership transfer
      expect(await ERC9988.ownerOf(1)).to.equal(account1.address);
    });
    
    it("Verifies ERC9988 compliance in fractional token transfers", async function() {
      const { ERC9988, owner, account1 } = await deployFixture();
      await ERC9988.connect(owner).mint(owner.address, [2]); // Mint and fractionalize
      
      // Assume token ID 1 is fractionalized, and owner tries to transfer fractional tokens
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1); // Transition to create fractional parts
      
      // Transfer fractional tokens from owner to account1 and verify ERC20 Transfer event
      await expect(ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1, 1, 2)) // Transfer 2 tokens of phase 1
        .to.emit(ERC9988, 'ERC9988Transfer') // Custom or equivalent event for ERC20 transfers
        .withArgs(owner.address, account1.address, 1, 1, 2);
      
      // Verify fractional token transfer
      const ownerBalanceAfter = await ERC9988.balanceOfPhase(1, 1, owner.address);
      const account1BalanceAfter = await ERC9988.balanceOfPhase(1, 1, account1.address);
      
      expect(ownerBalanceAfter).to.equal(0); // Owner transferred all fractional tokens out
      expect(account1BalanceAfter).to.equal(2); // Account1 received the fractional tokens
    });
    
    it("Ensures compliance with additional contract-specific events", async function() {
      const { ERC9988, owner } = await deployFixture();
      await ERC9988.connect(owner).mint(owner.address, [2, 3]); // Mint with phase multipliers
      
      // Example: Transitioning phase emits a custom contract-specific event
      await expect(ERC9988.connect(owner).transitionPhase(1, 0, 1, 1))
        .to.emit(ERC9988, 'TransferPhase')
        .withArgs(1, 0, 1, owner.address, 1);
      
    });
    
  })

  describe("ERC9988 - ERC721 Approval Tests", function() {
  
    it("Test that the approve function sets the correct approval for a given tokenId", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Mint a new token to the owner
      const phaseMultipliers = [2]; // Example phase multipliers
      await ERC9988.connect(owner).mint(owner.address, phaseMultipliers);
  
      // Approve account1 to manage the token
      await ERC9988.connect(owner).approve(account1.address, 1);
  
      // Fetch the approved address for the tokenId
      const approvedAddress = await ERC9988.getApproved(1);
  
      // Assert that the approved address matches account1
      expect(approvedAddress).to.equal(account1.address);
    });
  
    it("Test that the getApproved function returns the correct address for an approved tokenId", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Mint a new token to the owner and approve account1 for it
      await ERC9988.connect(owner).mint(owner.address, [2]);
      await ERC9988.connect(owner).approve(account1.address, 1);
  
      // Use getApproved to fetch the approved address
      const approved = await ERC9988.getApproved(1);
  
      // Assert that getApproved returns account1's address for tokenId 1
      expect(approved).to.equal(account1.address);
    });
  
    it("Test that the approve function emits the Approval event with correct parameters", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Mint a new token to the owner
      await ERC9988.connect(owner).mint(owner.address, [2]);
  
      // Expect the approve call to emit the Approval event with correct parameters
      await expect(ERC9988.connect(owner).approve(account1.address, 1))
        .to.emit(ERC9988, "Approval")
        .withArgs(owner.address, account1.address, 1);
    });

    it("Test that attempting to approve a tokenId that doesn't exist reverts appropriately", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Attempt to approve a non-existent token (assuming no tokens have been minted yet)
      await expect(ERC9988.connect(owner).approve(account1.address, 1))
        .to.be.revertedWithCustomError(ERC9988,"NonExistentToken()"); // Adjust error message as per your contract
    });
  
    it("Test that the setApprovalForAll function sets approval for all tokens owned by a caller", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Initially, account1 should not be approved
      let isApproved = await ERC9988.isApprovedForAll(owner.address, account1.address);
      expect(isApproved).to.be.false;
  
      // Set approval for all tokens
      await ERC9988.connect(owner).setApprovalForAll(account1.address, true);
  
      // Now, account1 should be approved
      isApproved = await ERC9988.isApprovedForAll(owner.address, account1.address);
      expect(isApproved).to.be.true;
    });
  
    it("Test that the isApprovedForAll function correctly reflects the approval status for an operator", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Initially, account1 should not be an operator
      expect(await ERC9988.isApprovedForAll(owner.address, account1.address)).to.equal(false);
  
      // Set account1 as an operator for owner
      await ERC9988.connect(owner).setApprovalForAll(account1.address, true);
  
      // Verify that account1 is now an operator
      expect(await ERC9988.isApprovedForAll(owner.address, account1.address)).to.equal(true);
  
      // Revoke the operator status
      await ERC9988.connect(owner).setApprovalForAll(account1.address, false);
  
      // Verify that account1 is no longer an operator
      expect(await ERC9988.isApprovedForAll(owner.address, account1.address)).to.equal(false);
    });

    it("Test that approval for a token is reset after a successful transfer", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
  
      // Mint a new token to the owner
      await ERC9988.connect(owner).mint(owner.address, [2]); // Use the correct parameters as per your minting function
  
      // Approve account1 to manage the token
      await ERC9988.connect(owner).approve(account1.address, 1);
  
      // Transfer the token from the owner to account2
      await ERC9988.connect(account1).transferFrom(owner.address, account2.address, 1);
  
      // Attempt to get the approved address for the tokenId after transfer
      const approvedAddressAfterTransfer = await ERC9988.getApproved(1);
  
      // Assert that the approval is reset (i.e., the approved address is the zero address)
      expect(approvedAddressAfterTransfer).to.equal("0x0000000000000000000000000000000000000000");
    });
  
    it("Test that setApprovalForAll remains unaffected by individual token transfers", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Mint a new token to the owner
      await ERC9988.connect(owner).mint(owner.address, [2]); // Adjust as per your contract
  
      // Set account1 as an operator for all tokens of the owner
      await ERC9988.connect(owner).setApprovalForAll(account1.address, true);
  
      // Transfer a token from the owner to another account (account1 here for simplicity)
      await ERC9988.connect(owner).transferFrom(owner.address, account1.address, 1);
  
      // Verify that account1 remains an operator for all tokens of the owner after the transfer
      const isOperatorAfterTransfer = await ERC9988.isApprovedForAll(owner.address, account1.address);
      expect(isOperatorAfterTransfer).to.be.true;
    });
  
    it("Ensures that approving a token does not inadvertently set approval for all tokens", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
  
      // Mint two new tokens to the owner
      await ERC9988.connect(owner).mint(owner.address, [2]); // Adjust as per your contract
      await ERC9988.connect(owner).mint(owner.address, [2]); // Adjust for the second token
  
      // Approve account1 to manage the first token only
      await ERC9988.connect(owner).approve(account1.address, 1);
  
      // Check that account1 is not set as an operator for all tokens
      const isOperatorForAll = await ERC9988.isApprovedForAll(owner.address, account1.address);
      expect(isOperatorForAll).to.be.false;
  
      // Additionally, ensure that account1 does not have approval for the second token
      const approvedAddressForSecondToken = await ERC9988.getApproved(2); // Assuming the second token ID is 2
      expect(approvedAddressForSecondToken).to.not.equal(account1.address);
    });
  });

  describe("ERC9988 - Phase Token Approval Tests", function() {
  
    it("Test that the approvePhaseToken function sets the correct phase token approval for a specified amount", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
      const phase = 1; // Example phase
      const amount = 100; // Example approval amount

      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)
  
      // Owner approves account1 to manage a specific amount of phase tokens
      await ERC9988.connect(owner).approvePhaseToken(1, phase, account1.address, amount);
  
      // Fetch the approved amount for account1 on phase tokens of tokenId 1
      const approvedAmount = await ERC9988.phaseAllowances(1, phase, owner.address, account1.address);
  
      // Assert the approved amount matches the specified amount
      expect(approvedAmount).to.equal(amount);
    });
  
    it("Test that an approved operator can transfer the correct amount of phase tokens on behalf of the owner", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
      const phase = 1; // Example phase
      const amount = 50; // Amount to be transferred
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)

      // Owner approves account1 for an amount
      await ERC9988.connect(owner).approvePhaseToken(1, phase, account1.address, amount);
  
      // Account1 transfers the approved amount of phase tokens to account2
      await ERC9988.connect(account1).transferFrom(owner.address, account2.address, 1, phase, amount);
  
      // Fetch the balance of account2 for the phase tokens
      const balanceOfAccount2 = await ERC9988.balanceOfPhase(1, phase, account2.address);
  
      // Assert that account2 received the amount
      expect(balanceOfAccount2).to.equal(amount);
    });
  
    it("Test that transferring more phase tokens than approved reverts appropriately", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
      const phase = 1; // Example phase
      const approvedAmount = 50; // Approved amount
      const transferAmount = 100; // Attempted transfer amount
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)

      // Owner approves account1 for a smaller amount than the attempted transfer
      await ERC9988.connect(owner).approvePhaseToken(1, phase, account1.address, approvedAmount);
  
      // Attempt to transfer more than the approved amount should fail
      await expect(
        ERC9988.connect(account1).transferFrom(owner.address, account2.address, 1, phase, transferAmount)
      ).to.be.revertedWith("ERC9988: NOT APPROVED FOR TRANSFER"); // Adjust based on your contract's error messages
    });
  
    it("Test that the approval for a specific phase token is reset to zero after a successful transfer", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
      const phase = 1; // Example phase
      const amount = 50; // Amount to be transferred
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)

      // Owner approves account1 for an amount
      await ERC9988.connect(owner).approvePhaseToken(1, phase, account1.address, amount);
  
      // Account1 transfers the approved amount of phase tokens to account2
      await ERC9988.connect(account1).transferFrom(owner.address, account2.address, 1, phase, amount);
  
      // Fetch the approved amount for account1 after the transfer
      const approvedAmountAfterTransfer = await ERC9988.phaseAllowances(1, phase, owner.address, account1.address);
  
      // Assert that the approval amount is reset to zero after the transfer
      expect(approvedAmountAfterTransfer).to.equal(0);
    });

    it("Approval is adjusted correctly after a phase token transfer", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
      const tokenId = 1; // Example tokenId
      const phase = 1; // Example phase
      const approvalAmount = 100;
      const transferAmount = 50; // Amount to be transferred, less than approval
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)

      // Owner approves account1 to manage some phase tokens
      await ERC9988.connect(owner).approvePhaseToken(tokenId, phase, account1.address, approvalAmount);
  
      // Account1 transfers some of these tokens to account2
      await ERC9988.connect(account1).transferFrom(owner.address, account2.address, tokenId, phase, transferAmount);
  
      // Fetch the updated approval amount
      const remainingApproval = await ERC9988.phaseAllowances(tokenId, phase, owner.address, account1.address);
  
      // Assert the remaining approval amount is adjusted correctly
      expect(remainingApproval).to.equal(approvalAmount - transferAmount);
    });
  
    it("Cannot transfer more phase tokens than the approved amount", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
      const tokenId = 1; // Example tokenId
      const phase = 1; // Example phase
      const approvalAmount = 50;
      const excessiveTransferAmount = 100; // Attempting to transfer more than approval
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)
      
      // Owner approves account1 for a specific amount of phase tokens
      await ERC9988.connect(owner).approvePhaseToken(tokenId, phase, account1.address, approvalAmount);
  
      // Attempting to transfer more than the approved amount should fail
      await expect(
        ERC9988.connect(account1).transferFrom(owner.address, account2.address, tokenId, phase, excessiveTransferAmount)
      ).to.be.revertedWith("ERC9988: NOT APPROVED FOR TRANSFER"); // Adjust the error message as per your contract
    });
  
    it("Approval for phase token is reset to zero after the full approved amount is transferred", async function() {
      const { owner, account1, account2, ERC9988 } = await deployFixture();
      const tokenId = 1; // Example tokenId
      const phase = 1; // Example phase
      const approvalAmount = 100;
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)

      // Owner approves account1 to manage an exact amount of phase tokens
      await ERC9988.connect(owner).approvePhaseToken(tokenId, phase, account1.address, approvalAmount);
  
      // Account1 transfers the full approved amount to account2
      await ERC9988.connect(account1).transferFrom(owner.address, account2.address, tokenId, phase, approvalAmount);
  
      // Fetch the approval amount after the transfer
      const approvalAfterTransfer = await ERC9988.phaseAllowances(tokenId, phase, owner.address, account1.address);
  
      // Assert the approval amount is reset to zero after the full amount is transferred
      expect(approvalAfterTransfer).to.equal(0);
    });
  
    it("Cannot transfer phase tokens without sufficient balance", async function() {
      const { owner, account1, ERC9988 } = await deployFixture();
      const tokenId = 1; // Example tokenId, assuming it has been minted and phase tokens are assigned
      const phase = 1; // Example phase
      const transferAmount = 100; // Amount attempting to transfer without having sufficient balance
  
      await ERC9988.connect(owner).mint(owner.address, [100]); // Adjust for the second token
      await ERC9988.connect(owner).transitionPhase(1, 0, 1, 1)

      // Assuming account1 does not have a sufficient amount of phase tokens
      // Attempt to transfer phase tokens should fail due to insufficient balance
      await expect(
        ERC9988.connect(account1).transferFrom(owner.address, account1.address, tokenId, phase, transferAmount)
      ).to.be.revertedWith("ERC9988: NOT APPROVED FOR TRANSFER"); // Use the appropriate error message as per your contract
    });
  });
  
});
