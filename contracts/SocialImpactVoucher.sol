//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//@dev - Import the Union Finance V1 SDK contracts from union-v1-sdk
import { UnionVoucher } from "./union-v1-sdk/UnionVoucher.sol";
import { UnionBorrower } from "./union-v1-sdk/UnionBorrower.sol";
import { BaseUnionMember } from "./union-v1-sdk/BaseUnionMember.sol";


/**
 * @title - Social Impact Voucher contract
 * @notice - A UnionMember that vouches for holders of membership NFTs
 */ 
contract SocialImpactVoucher is AccessControl, Ownable, UnionVoucher, UnionBorrower {

    uint256 public vouchAmount;
    IERC721 public npoNFT;

    //@dev - Roles
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
        _setupRole(NON_PROFIT_ORGANIZATION_ROLE, nonProfitOrganization);
    }


    ///----------------------------
    /// Methods to manage members
    ///----------------------------

    /**
     * @notice - Register a new member
     * @dev - Only the role of "Not Profit Organization" can add a new member 
     */ 
    function registerMember() public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(msg.sender, address(this), newMemberFee);
        _registerMember();
    }

    //@dev - Only a npoNFT holder can be vouched
    function vouchFornpoNFTHolder(address holder) public onlyOwner {
        require(npoNFT.balanceOf(holder) > 0, "!holder");
        _updateTrust(holder, vouchAmount);
    }


    ///-------------------------------------
    /// Methods to vouch
    ///-------------------------------------
    //@dev - Stop vouch for other member
    function cancelVouch(address staker, address borrower) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _cancelVouch(staker, borrower);
    }

    function stake(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _stake(amount);
    }

    function unstake(uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _unstake(amount);
        underlyingToken.transfer(msg.sender, amount);
    }

    function withdrawRewards() public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _withdrawRewards();
        unionToken.transfer(msg.sender, unionToken.balanceOf(address(this)));
    }
    
    function debtWriteOff(address borrower, uint256 amount) public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        _debtWriteOff(borrower, amount);
    }


    ///-------------------------------------
    /// Methods to borrow from credit line
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