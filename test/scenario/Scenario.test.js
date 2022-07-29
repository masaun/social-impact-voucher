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
    let NPO_NFT
    let NPO_NFT_FACTORY
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

        //@dev - Deployed-addresses on Mainnet
        USER_MANAGER = "0x49c910Ba694789B58F53BFF80633f90B8631c195"      // UserManager.sol
        MARKET_REGISTRY = "0x1ddB9a1F6Bc0dE1d05eBB0FDA61A7398641ae6BE"   // MarketRegistry.sol
        UNION_TOKEN = "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C"       // UnionToken.sol
        UNDERLYING_TOKEN = "0x6b175474e89094c44da98b954eedeac495271d0f"  // Underlying Token (DAI)
        DAI_TOKEN = "0x6b175474e89094c44da98b954eedeac495271d0f"
        U_TOKEN = "0x954F20DF58347b71bbC10c94827bE9EbC8706887"           // UToken.sol

        //@dev - Deploy the NpoNFTFactory.sol
        const NpoNFTFactory = await ethers.getContractFactory("NpoNFTFactory")
        npoNFTFactory = await NpoNFTFactory.deploy()

        const admin = "0xd83b4686e434b402c2ce92f4794536962b2be3e8"       //address has usermanager auth
        const daiWallet = "0x6262998Ced04146fA42253a5C0AF90CA02dfd2A3"   //account has dai
        const unionWallet = "0xfc32e7c7c55391ebb4f91187c91418bf96860ca9" //account has unionToken
        
        await network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [admin],
        })
        await network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [daiWallet],
        })
        await network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [unionWallet],
        })

        const signer = await ethers.provider.getSigner(admin)
        const daiSigner = await ethers.provider.getSigner(daiWallet)
        const unionSigner = await ethers.provider.getSigner(unionWallet)
        await OWNER.sendTransaction({ to: admin, value: parseEther("10") })
        await OWNER.sendTransaction({ to: unionWallet, value: parseEther("10") })

        //@dev - Create deployed-contract instances
        userManager = await ethers.getContractAt("IUserManager", USER_MANAGER)
        dai = await ethers.getContractAt("IERC20", DAI_TOKEN)
        unionToken = await ethers.getContractAt("IUnionToken", UNION_TOKEN)
        uToken = await ethers.getContractAt("IUToken", U_TOKEN)
    })

    it("createNewNpoNFT()", async () => {
        let tx = await npoNFTFactory.createNewNpoNFT(NPO_MEMBER_1)
        let txReceipt = await tx.wait()

        const eventName = "NpoNFTCreated"
        let eventLog = await getEventLog(txReceipt, eventName)
        console.log(`eventLog of "NpoNFTCreated": ${ eventLog }`)

        //@dev - Assign a NPO_NFT address created into instance
        NPO_NFT = eventLog[0]
        NPO_NFT.toString().should.eq(eventLog[0]);
    })

    it("Deploy the SocialImpactVoucher.sol and SocialImpactBorrower.sol", async () => {
        //@dev - Deploy the SocialImpactVoucher.sol
        const vouchAmount = parseEther("10000")
        const SocialImpactVoucher = await ethers.getContractFactory("SocialImpactVoucher")
        socialImpactVoucher = await SocialImpactVoucher.deploy(MARKET_REGISTRY, UNION_TOKEN, UNDERLYING_TOKEN, NPO_MEMBER_1, vouchAmount, NPO_NFT)

        //@dev - Deploy the SocialImpactBorrower.sol
        const SocialImpactBorrower = await ethers.getContractFactory("SocialImpactBorrower")
        socialImpactBorrower = await SocialImpactBorrower.deploy(MARKET_REGISTRY, UNION_TOKEN, UNDERLYING_TOKEN)
    })



        // const amount = parseEther("1000")

        // //@dev - Add each wallet addresses to members
        // await userManager.connect(signer).addMember(STAKER_A.address)
        // await userManager.connect(signer).addMember(STAKER_B.address)
        // await userManager.connect(signer).addMember(STAKER_C.address)
        // await dai.connect(daiSigner).transfer(STAKER_A.address, amount)
        // await dai.connect(daiSigner).transfer(STAKER_B.address, amount)
        // await dai.connect(daiSigner).transfer(STAKER_C.address, amount)
        // await dai.connect(daiSigner).transfer(OWNER.address, amount)
        // await dai.connect(STAKER_A).approve(userManager.address, amount)
        // await dai.connect(STAKER_B).approve(userManager.address, amount)
        // await dai.connect(STAKER_C).approve(userManager.address, amount)
        // await userManager.connect(STAKER_A).stake(amount)
        // await userManager.connect(STAKER_B).stake(amount)
        // await userManager.connect(STAKER_C).stake(amount)

        // //@dev - Update Trust (Vouch for specified-addresses)
        // await userManager.connect(STAKER_A).updateTrust(socialImpactVoucher.address, amount)
        // await userManager.connect(STAKER_B).updateTrust(socialImpactVoucher.address, amount)
        // await userManager.connect(STAKER_C).updateTrust(socialImpactVoucher.address, amount)
        // await userManager.connect(STAKER_A).updateTrust(socialImpactBorrower.address, amount)
        // await userManager.connect(STAKER_B).updateTrust(socialImpactBorrower.address, amount)
        // await userManager.connect(STAKER_C).updateTrust(socialImpactBorrower.address, amount)

        // await unionToken.connect(signer).disableWhitelist()
        // const fee = await userManager.newMemberFee()
        // await unionToken.connect(unionSigner).transfer(OWNER.address, fee.mul(2))
        // await unionToken.connect(OWNER).approve(socialImpactVoucher.address, fee)
        // await unionToken.connect(OWNER).approve(socialImpactBorrower.address, fee)

})