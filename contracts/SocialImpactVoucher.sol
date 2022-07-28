//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//@dev - OpenZeppelin
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
//import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//@dev - Import the Union Finance V1 SDK contracts from union-v1-sdk
import { UnionVoucher } from "./union-v1-sdk/UnionVoucher.sol";
import { UnionBorrower } from "./union-v1-sdk/UnionBorrower.sol";
import { BaseUnionMember } from "./union-v1-sdk/BaseUnionMember.sol";


/**
 * @title - Social Impact Voucher contract
 * @notice - A UnionMember that vouches for holders of membership NFTs
 */ 
contract SocialImpactVoucher is AccessControl, UnionVoucher, UnionBorrower {

    uint256 public vouchAmount;
    IERC721 public npoNFT;

    //@dev - Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant NON_PROFIT_ORGANIZATION_ROLE = keccak256("NON_PROFIT_ORGANIZATION_ROLE");

    /**
     *  @notice - Constructor
     *  @param marketRegistry - Union's MarketRegistry contract address
     *  @param unionToken - UNION token address
     *  @param token - Underlying asset address
     */ 
    constructor(address marketRegistry, address unionToken, address token, address nonProfitOrganization, uint _vouchAmount, IERC721 _npoNFT) BaseUnionMember(marketRegistry, unionToken, token) {
        //@dev - Member NFTs
        npoNFT = _npoNFT;
        vouchAmount = _vouchAmount;

        //@dev - Set roles
        _setupRole(ADMIN_ROLE, nonProfitOrganization);
        _setupRole(NON_PROFIT_ORGANIZATION_ROLE, nonProfitOrganization);
    }


    ///-------------------------------------
    /// Methods to vouch
    ///-------------------------------------

    //@dev - Only a npoNFT holder can be vouched
    function vouchForNpoNFTHolder(address holder) public onlyRole(ADMIN_ROLE) {
        require(npoNFT.balanceOf(holder) > 0, "!holder");
        _updateTrust(holder, vouchAmount);
    }

    //@dev - Stop vouch for other member
    function cancelVouch(address staker, address borrower) public {
        _cancelVouch(staker, borrower);
    }

    function stake(uint256 amount) public {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _stake(amount);
    }

    function unstake(uint256 amount) public {
        _unstake(amount);
        underlyingToken.transfer(msg.sender, amount);
    }

    function withdrawRewards() public {
        _withdrawRewards();
        unionToken.transfer(msg.sender, unionToken.balanceOf(address(this)));
    }
    
    function debtWriteOff(address borrower, uint256 amount) public {
        _debtWriteOff(borrower, amount);
    }


    ///-------------------------------------
    /// Methods to borrow from credit line based on voucher that a NPO has
    ///-------------------------------------
    function borrow(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _borrow(amount);
        underlyingToken.transfer(msg.sender, amount);
    }

    function repayBorrow(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _repayBorrow(amount);
    }

    function repayBorrowBehalf(address account, uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _repayBorrowBehalf(account, amount);
    }
    
    function mint(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _mint(amount);
    }
    
    // sender redeems uTokens in exchange for the underlying asset
    function redeem(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _redeem(amount);
        underlyingToken.transfer(msg.sender, underlyingToken.balanceOf(address(this)));
    }

    // sender redeems uTokens in exchange for a specified amount of underlying asset
    function redeemUnderlying(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _redeemUnderlying(amount);
        underlyingToken.transfer(msg.sender, underlyingToken.balanceOf(address(this)));
    }

}