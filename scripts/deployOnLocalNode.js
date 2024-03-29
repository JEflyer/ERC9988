const {ethers} = require("ethers")
const {abi:FTabi , bytecode: FTbytecode } =require("../artifacts/contracts/MyERC9988.sol/MySupplyChainToken.json")
const {abi:marketABI , bytecode: marketBYTECODE} = require("../artifacts/contracts/ERC9988Marketplace.sol/ERC9988Marketplace.json")
const {abi:tokenABI, bytecode: tokenBytecode} = require("../artifacts/contracts/token.sol/TestToken.json")
require("dotenv").config()

const private1 = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
const private2 = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
const rpc = "http://127.0.0.1:8545/"
const provider = new ethers.JsonRpcProvider(rpc)
const wallet1 = new ethers.Wallet(private1,provider)
const wallet2 = new ethers.Wallet(private2,provider)

const FTFactory = new ethers.ContractFactory(FTabi,FTbytecode,wallet1)
const marketFactory = new ethers.ContractFactory(marketABI,marketBYTECODE,wallet1)
const tokenFactory = new ethers.ContractFactory(tokenABI,tokenBytecode,wallet1)

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function start(){

    console.log("Deploying mUSDC")
    let mUSDC = await tokenFactory.deploy("mUSDC","USDC")
    // await mUSDC.deployed()
    console.log(`mUSDC deployed @ ${mUSDC.target}`)

    await sleep(1000)

    console.log("Deploying mWMATIC")
    let mWMATIC = await tokenFactory.deploy("mWMATIC","WMATIC")
    // await mWMATIC.deployed()
    console.log(`mWMATIC deployed @ ${mWMATIC.target}`)
    await sleep(1000)

    console.log("Deploying ERC9988 minter")
    // constructor(
    //     string memory name_,
    //     string memory symbol_,
    //     string memory baseTokenURI_,
    //     string memory basePhaseURI_, 
    //     address usdcAddress, 
    //     address wmaticAddress
    let ERC9988Minter = await FTFactory.deploy(
        "King of Fractionalisation",
        "KoF",
        "This is a baseTokenURI",
        "This is a basePhaseURI",
        mUSDC.target,
        mWMATIC.target
    )
    // await ERC9988Minter.deployed()
    console.log(`ERC9988 Minter deployed @ ${ERC9988Minter.target}`)
    await sleep(1000)

    console.log("Deploying marketplace")
    // constructor(address _erc9988Address)
    let marketplace = await marketFactory.deploy(
        ERC9988Minter.target,
        mUSDC.target,
        mWMATIC.target,
        "0x224B8f20ae6661C008724d130de6185a75FBc6f7"
    )
    // await marketplace.deployed()
    console.log(`Marketplace deployed @ ${marketplace.target}`)
    await sleep(1000)

    let tx1 =await ERC9988Minter.mint(
        wallet1.address,
        [
            69,99,150,200,420
        ]
    )
    await tx1.wait()
    await sleep(1000)

    let tx2 = await ERC9988Minter.transitionPhase(1, 0, 1, 1);
    await tx2.wait()
    await sleep(1000)
    
    let tx3 = await ERC9988Minter.approvePhaseToken(1, 1, marketplace.target, 10);
    await tx3.wait()
    await sleep(1000)
    
    let tx4 = await marketplace.addAcceptedCurrency(mUSDC.target, true);
    await tx4.wait()
    await sleep(1000)

    const tokenId = 1;
    const phase = 1;
    const amount = 10;
    const price = ethers.parseUnits("100", "ether");
    let tx5 = await marketplace.createListing(tokenId, phase, amount, price, mUSDC.target);
    await tx5.wait()
    await sleep(1000)

    // Simulate the buyer having enough currency
    let tx6 = await mUSDC.transfer(wallet2.address, price);
    await tx6.wait()
    await sleep(1000)
    
    let tx7 = await (new ethers.Contract(mUSDC.target,tokenABI,wallet2)).approve(marketplace.target, price);
    await tx7.wait()
    await sleep(1000)
    
    // Execute purchase
    let tx8 = await (new ethers.Contract(marketplace.target,marketABI,wallet2)).buy(1)
    await tx8.wait()
    await sleep(1000)
}

start()