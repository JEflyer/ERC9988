const {ethers} = require("ethers")
const {abi:FTabi } =require("../artifacts/contracts/MyERC9988.sol/MySupplyChainToken.json")
require("dotenv").config()

const private = process.env.PRIVATE1
const rpc = process.env.RPC
const provider = new ethers.JsonRpcProvider(rpc)
const wallet = new ethers.Wallet(private,provider)

const FT = new ethers.Contract("0xED77d8CC861C613c02959BbFaeD2019238347C9b",FTabi,wallet)

async function start(){

    await FT.mint(
        wallet.address,
        [
            69,99,150,200,420
        ]
    )


}

start()