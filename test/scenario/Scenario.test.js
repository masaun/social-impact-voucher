const { ethers } = require("hardhat")
const { parseEther } = ethers.utils
const { toWei, fromWei, getEventLog } = require("../ethersjs-helper/ethersjsHelper")
require("chai").should()


/**
 * @title - Scenario Test
 */ 
describe("Scenario Test", async () => {

    //@dev - Smart contract instances
    let npoNFTFactory, userManager, dai, unionToken, uToken;

    //@dev - Smart contract addresses
    let MARKET_REGISTRY    // MarketRegistry.sol
    let UNION_TOKEN        // UnionToken.sol
    let UNDERLYING_TOKEN   // Underlying Token 

    //@dev - Non Profit Organization (wallet address)
    let NPO_MEMBER_1

    before(async () => {

        //@dev - Mainnet-forking test
        await network.provider.request({
            method: "hardhat_reset",
            params: [
                {
                    forking: {
                        jsonRpcUrl:
                          "https://eth-mainnet.alchemyapi.io/v2/" + 
                          process.env.ALCHEMY_API_KEY,
                        blockNumber: 14314100, // UNION mainnet deployment
                    },
                },
            ],
        });

        [OWNER, STAKER_A, STAKER_B, STAKER_C, USER, npoMember1] = await ethers.getSigners();

        NPO_MEMBER_1 = npoMember1.address 

        MARKET_REGISTRY = "0x1ddB9a1F6Bc0dE1d05eBB0FDA61A7398641ae6BE"   // MarketRegistry.sol
        UNION_TOKEN = "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C"       // UnionToken.sol
        UNDERLYING_TOKEN = "0x6b175474e89094c44da98b954eedeac495271d0f"  // Underlying Token 

        const NpoNFTFactory = await ethers.getContractFactory("NpoNFTFactory");
        npoNFTFactory = await NpoNFTFactory.deploy()
    })

    it("createNewNpoNFT()", async () => {
        let tx = await npoNFTFactory.createNewNpoNFT(NPO_MEMBER_1)
        let txReceipt = await tx.wait()

        const eventName = "NpoNFTCreated"
        let eventLog = await getEventLog(txReceipt, eventName)
        console.log(`eventLog of "NpoNFTCreated": ${ eventLog }`)
    })

})