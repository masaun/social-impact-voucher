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
    let SOCIAL_IMPACT_VOUCHER
    let SOCIAL_IMPACT_BORROWER
    let MEMBER_REGISTRY    // MemberRegistry.sol
    let MARKET_REGISTRY    // MarketRegistry.sol
    let UNION_TOKEN        // UnionToken.sol
    let UNDERLYING_TOKEN   // Underlying Token 

    //@dev - wallet addresses
    let OWNER, STAKER_A, STAKER_B, STAKER_C, USER, NPO_MEMBER_1

    //@dev - Signers
    let signer
    let daiSigner
    let unionSigner
    let owner, stakerA, stakerB, stakerC, user, npoMember1

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

        //@dev - Get signers of each accounts
        [owner, stakerA, stakerB, stakerC, user, npoMember1] = await ethers.getSigners();

        //@dev - Get wallet addresses of each accounts
        OWNER = owner.address
        STAKER_A = stakerA.address
        STAKER_B = stakerB.address
        STAKER_C = stakerC.address
        USER = user.address
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
        NPO_NFT_FACTORY = npoNFTFactory.address
        console.log(`Deployed-address of the NpoNFTFactory contract: ${ NPO_NFT_FACTORY }`)

        //@dev - Deploy the MemberRegistry.sol
        const MemberRegistry = await ethers.getContractFactory("MemberRegistry")
        memberRegistry = await MemberRegistry.deploy(MARKET_REGISTRY, UNION_TOKEN, UNDERLYING_TOKEN, NPO_NFT_FACTORY)
        MEMBER_REGISTRY = memberRegistry.address
        console.log(`Deployed-address of the MemberRegistry contract: ${ MEMBER_REGISTRY }`)

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

        signer = await ethers.provider.getSigner(admin)
        daiSigner = await ethers.provider.getSigner(daiWallet)
        unionSigner = await ethers.provider.getSigner(unionWallet)
        await owner.sendTransaction({ to: admin, value: parseEther("10") })
        await owner.sendTransaction({ to: unionWallet, value: parseEther("10") })

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
        NPO_NFT.toString().should.eq(eventLog[0])
    })

    it("Deploy the SocialImpactVoucher.sol and SocialImpactBorrower.sol", async () => {
        //@dev - Deploy the SocialImpactVoucher.sol
        const vouchAmount = parseEther("10000")
        const SocialImpactVoucher = await ethers.getContractFactory("SocialImpactVoucher")
        socialImpactVoucher = await SocialImpactVoucher.deploy(MARKET_REGISTRY, UNION_TOKEN, UNDERLYING_TOKEN, NPO_MEMBER_1, vouchAmount, NPO_NFT_FACTORY)
        SOCIAL_IMPACT_VOUCHER = socialImpactVoucher.address
        console.log(`Deployed-address of the SocialImpactVoucher contract: ${ SOCIAL_IMPACT_VOUCHER }`)

        //@dev - Deploy the SocialImpactBorrower.sol
        const SocialImpactBorrower = await ethers.getContractFactory("SocialImpactBorrower")
        socialImpactBorrower = await SocialImpactBorrower.deploy(MARKET_REGISTRY, UNION_TOKEN, UNDERLYING_TOKEN)
        SOCIAL_IMPACT_BORROWER = socialImpactBorrower.address
        console.log(`Deployed-address of the SocialImpactBorrower contract: ${ SOCIAL_IMPACT_BORROWER }`)
    })

    it("updateTrust() - Vouch for specified-addresses", async () => {
        const amount = parseEther("1000")

        //@dev - Add each wallets addresses to members
        await userManager.connect(signer).addMember(STAKER_A)
        await userManager.connect(signer).addMember(STAKER_B)
        await userManager.connect(signer).addMember(STAKER_C)
        await dai.connect(daiSigner).transfer(STAKER_A, amount)
        await dai.connect(daiSigner).transfer(STAKER_B, amount)
        await dai.connect(daiSigner).transfer(STAKER_C, amount)
        await dai.connect(daiSigner).transfer(OWNER, amount)
        await dai.connect(stakerA).approve(USER_MANAGER, amount)
        await dai.connect(stakerB).approve(USER_MANAGER, amount)
        await dai.connect(stakerC).approve(USER_MANAGER, amount)
        await userManager.connect(stakerA).stake(amount)
        await userManager.connect(stakerB).stake(amount)
        await userManager.connect(stakerC).stake(amount)

        //@dev - Vouch for specified-addresses
        await userManager.connect(stakerA).updateTrust(socialImpactVoucher.address, amount)
        await userManager.connect(stakerB).updateTrust(socialImpactVoucher.address, amount)
        await userManager.connect(stakerC).updateTrust(socialImpactVoucher.address, amount)
        await userManager.connect(stakerA).updateTrust(socialImpactBorrower.address, amount)
        await userManager.connect(stakerB).updateTrust(socialImpactBorrower.address, amount)
        await userManager.connect(stakerC).updateTrust(socialImpactBorrower.address, amount)
    })

    it("Setup new member fee", async () => {
        await unionToken.connect(signer).disableWhitelist()
        const fee = await userManager.newMemberFee()
        await unionToken.connect(unionSigner).transfer(OWNER, fee.mul(2))
        await unionToken.connect(owner).approve(memberRegistry.address, fee)
        await unionToken.connect(owner).approve(memberRegistry.address, fee)
    })

    it("Register member as a NPO member", async () => {
        let isMember = await memberRegistry.isMember()
        isMember.should.eq(false)

        //[Error]: "<UnrecognizedContract>.<unknown> (0x49c910ba694789b58f53bff80633f90b8631c195)"
        //let tx = await socialImpactVoucher.registerMemberAsNPO()
        let tx = await memberRegistry.registerMemberAsNPO()
        let txReceipt = await tx.wait()
        isMember = await memberRegistry.isMember()
        isMember.should.eq(true)
    })

    it("Register member as a Supporter member", async () => {
        let isMember = await memberRegistry.isMember()
        isMember.should.eq(false)

        //[Error]: "<UnrecognizedContract>.<unknown> (0x49c910ba694789b58f53bff80633f90b8631c195)"
        //let tx = await socialImpactVoucher.registerMemberAsSupporter()
        let tx = await memberRegistry.registerMemberAsSupporter()
        let txReceipt = await tx.wait()
        isMember = await memberRegistry.isMember()
        isMember.should.eq(true)
    })

})