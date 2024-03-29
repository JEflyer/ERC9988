const {ethers} = require("ethers")
const {abi:FTabi } =require("../artifacts/contracts/MyERC9988.sol/KingOfFractionalisation.json")
require("dotenv").config()

const private = process.env.PRIVATE1
const rpc = process.env.RPC
const provider = new ethers.JsonRpcProvider(rpc)
const wallet = new ethers.Wallet(private,provider)

const FT = new ethers.Contract("0x437d942125e9A0737C69E2e640A1b2674BB345ae",FTabi,wallet)

async function start(){

    await FT.mint(
        wallet.address,
        [
            69,99,150,300,420
        ]
    )


}

start()