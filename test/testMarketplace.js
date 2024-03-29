const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("ERC9988Marketplace", function() {
  async function deployMarketplaceFixture() {
    const [owner, account1, winningPot] = await ethers.getSigners();
    
    // Mock ERC20 for test currencies
    const TestToken = await ethers.getContractFactory("TestToken");
    const testCurrency1 = await TestToken.deploy("Name","Sym");
    const testCurrency2 = await TestToken.deploy("Name","Sym");
    
    // Deploy your ERC9988 and ERC9988Marketplace contracts
    const ERC9988 = await ethers.getContractFactory("KingOfFractionalisation");
    const erc9988 = await ERC9988.deploy("Name", "Symbol", "baseURI", "basePhaseURI", testCurrency1.target, testCurrency2.target);
    
    const ERC9988Marketplace = await ethers.getContractFactory("ERC9988Marketplace");
    const marketplace = await ERC9988Marketplace.deploy(erc9988.target, testCurrency1.target, testCurrency2.target, winningPot.address);
    
    return { owner, account1, winningPot, testCurrency1, testCurrency2, marketplace, erc9988 };
  }

  // Using a fixture to deploy contracts
  async function deployFixture() {
    return loadFixture(deployMarketplaceFixture);
  }

  describe("Adding and Removing Accepted Currencies", function() {
    it("Should allow the owner to add a new accepted currency", async function() {
      const { owner, testCurrency1, marketplace } = await deployFixture();
      
      await expect(marketplace.addAcceptedCurrency(testCurrency1.target, true))
        .to.emit(marketplace, "CurrencyAccepted")
        .withArgs(testCurrency1.target, true);
      
      expect(await marketplace.acceptedCurrencies(testCurrency1.target)).to.equal(true);
    });

    it("Should allow the owner to remove an accepted currency", async function() {
      const { owner, testCurrency1, marketplace } = await deployFixture();
      
      // First add a currency
      await marketplace.addAcceptedCurrency(testCurrency1.target, true);
      
      // Then remove it
      await expect(marketplace.addAcceptedCurrency(testCurrency1.target, false))
        .to.emit(marketplace, "CurrencyAccepted")
        .withArgs(testCurrency1.target, false);
      
      expect(await marketplace.acceptedCurrencies(testCurrency1.target)).to.equal(false);
    });

    it("Should revert if a non-owner tries to add or remove an accepted currency", async function() {
      const { account1, testCurrency1, marketplace } = await deployFixture();
      
      await expect(marketplace.connect(account1).addAcceptedCurrency(testCurrency1.target, true))
        .to.be.revertedWithCustomError(marketplace,"OwnableUnauthorizedAccount(address)");
    });
  });

  describe("createListing", function() {
    it("Should allow a successful listing creation", async function() {
      const { owner, testCurrency1, marketplace, erc9988 } = await deployFixture();
  
      // Additional setup: mint an ERC9988 token to owner
      // Assume minting function exists and sets up tokens for tests
      // Adjust according to your contract's API
      await erc9988.connect(owner).mint(owner.address, [10]); // Example for minting a token
    //   function transitionPhase(uint256 parentTokenId, uint256 phaseFrom, uint256 phaseTo, uint256 amount) public {
      await erc9988.connect(owner).transitionPhase(1,0,1,1)
      await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
      // Assume `testCurrency1` is already accepted as a payment currency
      await marketplace.addAcceptedCurrency(testCurrency1.target, true);
  
      const tokenId = 1;
      const phase = 1;
      const amount = 10;
      const price = ethers.parseUnits("100", "ether");
  
      // Create a listing
      await expect(marketplace.createListing(tokenId, phase, amount, price, testCurrency1.target))
        .to.emit(marketplace, "ListingCreated")
        .withArgs(1, owner.address, tokenId, phase, amount, price, testCurrency1.target);
    });
  
    it("Should revert when trying to create a listing with unaccepted currency", async function() {
      const { owner, testCurrency2, marketplace, erc9988 } = await deployFixture();
      await erc9988.connect(owner).mint(owner.address, [2]); // Mint a token for listing
  
      const tokenId = 1;
      const phase = 1;
      const amount = 10;
      const price = ethers.parseUnits("100", "ether");
  
      // Attempt to create a listing with an unaccepted currency
      await expect(marketplace.createListing(tokenId, phase, amount, price, owner.address))
        .to.be.revertedWith("Currency not accepted for payments");
    });
  
    it("Should revert when trying to create a listing with insufficient token balance", async function() {
      const { owner, testCurrency1, marketplace, erc9988 } = await deployFixture();
      await erc9988.connect(owner).mint(owner.address, [2]); // Mint a token for listing
      await marketplace.addAcceptedCurrency(testCurrency1.target, true);
  
      const tokenId = 1;
      const phase = 1;
      const insufficientAmount = 1000; // Assumed to be more than the owner has
      const price = ethers.parseUnits("100", "ether");
  
      // Attempt to create a listing with insufficient token balance
      await expect(marketplace.createListing(tokenId, phase, insufficientAmount, price, testCurrency1.target))
        .to.be.revertedWith("Insufficient balance for this phase");
    });
  
    it("Should revert when trying to create a listing with a price of zero", async function() {
      const { owner, testCurrency1, marketplace, erc9988 } = await deployFixture();
      await erc9988.connect(owner).mint(owner.address, [2]); // Mint a token for listing
      await marketplace.addAcceptedCurrency(testCurrency1.target, true);
  
      const tokenId = 1;
      const phase = 1;
      const amount = 10;
      const zeroPrice = ethers.parseUnits("0", "ether");
  
      // Attempt to create a listing with a price of zero
      await expect(marketplace.createListing(tokenId, phase, amount, zeroPrice, testCurrency1.target))
        .to.be.revertedWith("Price must be greater than zero");
    });
  
    it("Emits a ListingCreated event upon successful listing creation", async function() {
      const { owner, testCurrency1, marketplace, erc9988 } = await deployFixture();
      await erc9988.connect(owner).mint(owner.address, [10]); // Mint a token for listing
      await erc9988.connect(owner).transitionPhase(1,0,1,1)
      await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
      await marketplace.addAcceptedCurrency(testCurrency1.target, true);
  
      const tokenId = 1;
      const phase = 1;
      const amount = 10;
      const price = ethers.parseUnits("100", "ether");
  
      // Verify that ListingCreated event is emitted with correct details
      await expect(marketplace.createListing(tokenId, phase, amount, price, testCurrency1.target))
        .to.emit(marketplace, "ListingCreated")
        .withArgs(1, owner.address, tokenId, phase, amount, price, testCurrency1.target);
    });
  });

  describe("buy", function() {
    it("Allows a successful purchase", async function() {
      const { owner, account1, testCurrency1, marketplace, erc9988 } = await deployFixture();
      await erc9988.connect(owner).mint(owner.address, [10]);
      await erc9988.connect(owner).transitionPhase(1, 0, 1, 1);
      await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
      await marketplace.addAcceptedCurrency(testCurrency1.target, true);
  
      const tokenId = 1;
      const phase = 1;
      const amount = 10;
      const price = ethers.parseUnits("100", "ether");
      await marketplace.createListing(tokenId, phase, amount, price, testCurrency1.target);
  
      // Simulate the buyer having enough currency
      await testCurrency1.connect(owner).transfer(account1.address, price);
      await testCurrency1.connect(account1).approve(marketplace.target, price);
  
      // Execute purchase
      await expect(marketplace.connect(account1).buy(1))
        .to.emit(marketplace, "Purchase")
        .withArgs(1, account1.address, tokenId, phase, amount, price, testCurrency1.target);
    });
  
    it("Reverts on purchase with insufficient currency", async function() {
        const { owner, account1, testCurrency1, marketplace, erc9988 } = await deployFixture();
      
        // Mint an ERC9988 token and prepare it for listing
        await erc9988.connect(owner).mint(owner.address, [10]);
        await erc9988.connect(owner).transitionPhase(1, 0, 1, 1);
        await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
      
        // Ensure testCurrency1 is accepted and account1 has insufficient funds
        await marketplace.addAcceptedCurrency(testCurrency1.target, true);
        const price = ethers.parseUnits("100", "ether"); // Listing price
        const insufficientPrice = ethers.parseUnits("50", "ether"); // Insufficient buyer's funds
        await testCurrency1.connect(owner).transfer(account1.address, insufficientPrice);
        await testCurrency1.connect(account1).approve(marketplace.target, insufficientPrice);
      
        // Create a listing for testing
        await marketplace.createListing(1, 1, 10, price, testCurrency1.target);
      
        // Attempt to purchase without sufficient currency should revert
        // This assumes the contract checks for the buyer's balance and reverts if insufficient
        await expect(marketplace.connect(account1).buy(1))
          .to.be.revertedWithCustomError(testCurrency1,"ERC20InsufficientAllowance"); // Use the actual error message your contract emits for insufficient ERC20 balance during transfers
      });
      
  
    it("Reverts when purchasing a non-existent listing", async function() {
      const { account1, marketplace } = await deployFixture();
  
      // Attempt to purchase a non-existent listing
      await expect(marketplace.connect(account1).buy(999)) // Assuming listing ID 999 does not exist
        .to.be.revertedWith("Listing does not exist or has been sold");
    });
      
  
    it("Verifies correct fee distribution upon purchase", async function() {
        const { owner, account1, winningPot, testCurrency1, marketplace, erc9988 } = await deployFixture();
        await erc9988.connect(owner).mint(owner.address, [10]);
        await erc9988.connect(owner).transitionPhase(1, 0, 1, 1);
        await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
        await marketplace.addAcceptedCurrency(testCurrency1.target, true);
  
        const tokenId = 1;
        const phase = 1;
        const amount = 10;
        const price = ethers.parseUnits("100", "ether");
        await marketplace.createListing(tokenId, phase, amount, price, testCurrency1.target);
  
        // Buyer preparation
        await testCurrency1.connect(owner).transfer(account1.address, price);
        await testCurrency1.connect(account1).approve(marketplace.target, price);
  
        // Capture initial balances
        const initialOwnerBalance = await testCurrency1.balanceOf(owner.address);
        const initialWinningPotBalance = await testCurrency1.balanceOf(winningPot.address);
  
        // Execute purchase
        await marketplace.connect(account1).buy(1);
  
        // Check fee distribution
        const fee = price * BigInt(2) / BigInt(100);// Assuming a 2% fee
        const expectedOwnerBalance = initialOwnerBalance + (fee / BigInt(2)) + (price - fee); // Assuming 50% of the fee goes to the owner
        const expectedWinningPotBalance = initialWinningPotBalance + (fee / BigInt(2)); // Assuming 50% of the fee goes to the winning pot
  
        expect(await testCurrency1.balanceOf(owner.address)).to.equal(expectedOwnerBalance);
        expect(await testCurrency1.balanceOf(winningPot.address)).to.equal(expectedWinningPotBalance);
      });
  
      it("Emits a Purchase event upon successful purchase", async function() {
        const { owner, account1, testCurrency1, marketplace, erc9988 } = await deployFixture();
      
        // Mint an ERC9988 token and prepare it for listing
        await erc9988.connect(owner).mint(owner.address, [10]);
        await erc9988.connect(owner).transitionPhase(1, 0, 1, 1);
        await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
      
        // Ensure testCurrency1 is accepted and account1 has sufficient funds
        await marketplace.addAcceptedCurrency(testCurrency1.target, true);
        const price = ethers.parseUnits("100", "ether");
        await testCurrency1.connect(owner).transfer(account1.address, price);
        await testCurrency1.connect(account1).approve(marketplace.target, price);
      
        // Create a listing for testing
        await marketplace.createListing(1, 1, 10, price, testCurrency1.target);
      
        // Execute purchase and check for Purchase event
        await expect(marketplace.connect(account1).buy(1))
          .to.emit(marketplace, "Purchase")
          .withArgs(1, account1.address, 1, 1, 10, price, testCurrency1.target);
      });
      
  });
  
  describe("cancelListing", function() {
    it("Allows the seller to successfully cancel a listing", async function() {
        const { owner, marketplace, erc9988, testCurrency1 } = await deployFixture();

        // Setup: Create a listing
        await erc9988.connect(owner).mint(owner.address, [10]);
        await erc9988.connect(owner).transitionPhase(1, 0, 1, 1);
        await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
        await marketplace.addAcceptedCurrency(testCurrency1.target, true);
        const price = ethers.parseUnits("100", "ether");
        await marketplace.createListing(1, 1, 10, price, testCurrency1.target);

        // Cancel the listing
        await expect(marketplace.cancelListing(1))
            .to.emit(marketplace, "ListingCancelled")
            .withArgs(1, owner.address);

        // Verify the listing is removed or marked as cancelled
        // Assuming your contract marks cancelled listings in a certain way
        // This might require querying a public state variable or a getter function
        const listing = await marketplace.listings(1);
        expect(listing.amount).to.equal(0); // Example verification, adjust based on your contract's logic
    });

    it("Reverts when trying to cancel a non-existent listing", async function() {
        const { owner, marketplace } = await deployFixture();
        
        // Attempt to cancel a listing that does not exist
        await expect(marketplace.cancelListing(999)) // Assuming listing ID 999 does not exist
            .to.be.revertedWith("Only the seller can cancel this listing");
    });

    it("Reverts when a non-seller tries to cancel a listing", async function() {
        const { owner, account1, marketplace, erc9988, testCurrency1 } = await deployFixture();
        
        // Setup: Owner creates a listing
        await erc9988.connect(owner).mint(owner.address, [10]);
        await erc9988.connect(owner).transitionPhase(1, 0, 1, 1);
        await erc9988.connect(owner).approvePhaseToken(1, 1, marketplace.target, 10);
        await marketplace.addAcceptedCurrency(testCurrency1.target, true);
        const price = ethers.parseUnits("100", "ether");
        await marketplace.createListing(1, 1, 10, price, testCurrency1.target);
        
        // Attempt to cancel the listing by a non-seller
        await expect(marketplace.connect(account1).cancelListing(1))
            .to.be.revertedWith("Only the seller can cancel this listing");
    });
});

  
});
