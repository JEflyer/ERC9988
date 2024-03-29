const {ethers} = require("ethers")
const {abi:FTabi , bytecode: FTbytecode } =require("../artifacts/contracts/MyERC9988.sol/KingOfFractionalisation.json")
const {abi:marketABI , bytecode: marketBYTECODE} = require("../artifacts/contracts/ERC9988Marketplace.sol/ERC9988Marketplace.json")
// const {abi:tokenABI, bytecode: tokenBytecode} = require("../artifacts/contracts/token.sol/TestToken.json")
require("dotenv").config()

const private = process.env.PRIVATE1
const rpc = process.env.RPC
const provider = new ethers.JsonRpcProvider(rpc)
const wallet = new ethers.Wallet(private,provider)

const FTFactory = new ethers.ContractFactory(FTabi,FTbytecode,wallet)
const marketFactory = new ethers.ContractFactory(marketABI,marketBYTECODE,wallet)
// const tokenFactory = new ethers.ContractFactory(tokenABI,tokenBytecode,wallet)

async function start(){

    // console.log("Deploying mUSDC")
    // let mUSDC = await tokenFactory.deploy("mUSDC","USDC")
    // // await mUSDC.deployed()
    // console.log(`mUSDC deployed @ ${mUSDC.target}`)

    // console.log("Deploying mWMATIC")
    // let mWMATIC = await tokenFactory.deploy("mWMATIC","WMATIC")
    // // await mWMATIC.deployed()
    // console.log(`mWMATIC deployed @ ${mWMATIC.target}`)

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
        "https://tomato-weak-haddock-410.mypinata.cloud/ipfs/QmeYRagKMYYfyygNgvYbCSsgm1nCyJQz9MwLHmkH9fii6G",//TokenURI
        "https://tomato-weak-haddock-410.mypinata.cloud/ipfs/QmUb6Bny9XjztoqbZzjEck9ghM47ZjPCtTL6c7Lk6bFqby",//PhaseURI
        "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",//USDC
        "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"//WMATIC
    )
    // await ERC9988Minter.deployed()
    console.log(`ERC9988 Minter deployed @ ${ERC9988Minter.target}`)

    console.log("Deploying marketplace")
    // constructor(
    //     address _erc9988Address, 
    //     address usdcAddress, 
    //     address wmaticAddress,
    //     address winningPotAddress
    let marketplace = await marketFactory.deploy(
        ERC9988Minter.target,
        "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",//USDC
        "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",//WMATIC
        "0xa2510505c432fde546590b91469394Bb033e8884"//Prize Pool wallet
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