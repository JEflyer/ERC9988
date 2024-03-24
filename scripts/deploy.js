const {ethers} = require("ethers")
const {abi:FTabi , bytecode: FTbytecode } =require("../artifacts/contracts/MyERC9988.sol/MySupplyChainToken.json")
const {abi:marketABI , bytecode: marketBYTECODE} = require("../artifacts/contracts/ERC9988Marketplace.sol/ERC9988Marketplace.json")
const {abi:tokenABI, bytecode: tokenBytecode} = require("../artifacts/contracts/token.sol/TestToken.json")
require("dotenv").config()

const private = process.env.PRIVATE1
const rpc = process.env.RPC
const provider = new ethers.JsonRpcProvider(rpc)
const wallet = new ethers.Wallet(private,provider)

const FTFactory = new ethers.ContractFactory(FTabi,FTbytecode,wallet)
const marketFactory = new ethers.ContractFactory(marketABI,marketBYTECODE,wallet)
const tokenFactory = new ethers.ContractFactory(tokenABI,tokenBytecode,wallet)

async function start(){

    console.log("Deploying mUSDC")
    let mUSDC = await tokenFactory.deploy()
    // await mUSDC.deployed()
    console.log(`mUSDC deployed @ ${mUSDC.target}`)

    console.log("Deploying mWMATIC")
    let mWMATIC = await tokenFactory.deploy()
    // await mWMATIC.deployed()
    console.log(`mWMATIC deployed @ ${mWMATIC.target}`)

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

    console.log("Deploying marketplace")
    // constructor(address _erc9988Address)
    let marketplace = await marketFactory.deploy(
        ERC9988Minter.target,
        mUSDC.target,
        mWMATIC.target
    )
    // await marketplace.deployed()
    console.log(`Marketplace deployed @ ${marketplace.target}`)

    // console.log("Adding mUSDC to Marketplace")
    // // function addAcceptedCurrency(address currency, bool status)
    // let tx1 = await marketplace.addAcceptedCurrency(mUSDC.target,true)
    // await tx1.wait()
    // console.log("mUSDC added")

    // console.log("Adding mWMATIC to Marketplace")
    // // function addAcceptedCurrency(address currency, bool status)
    // let tx2 = await marketplace.addAcceptedCurrency(mWMATIC.target,true)
    // await tx2.wait()
    // console.log("mWMATIC added")



}

start()