//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

//@dev - Import the Union Finance V1 SDK contracts from union-v1-sdk
import { UnionVoucher } from "./union-v1-sdk/UnionVoucher.sol";
import { UnionBorrower } from "./union-v1-sdk/UnionBorrower.sol";
import { BaseUnionMember } from "./union-v1-sdk/BaseUnionMember.sol";


/**
 * @title - Social Impact Vouch contract
 */ 
contract SocialImpactVouch is AccessControl, Ownable, UnionVoucher, UnionBorrower {

    //@dev - Roles
    bytes32 public constant NON_PROFIT_ORGANIZATION_ROLE = keccak256("NON_PROFIT_ORGANIZATION_ROLE");

    /**
     *  @notice - Constructor
     *  @param marketRegistry - Union's MarketRegistry contract address
     *  @param unionToken - UNION token address
     *  @param token - Underlying asset address
     */ 
    constructor(address marketRegistry, address unionToken, address token, address nonProfitOrganization) BaseUnionMember(marketRegistry, unionToken, token) {
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

    // update trust for account
    function updateTrust(address account, uint256 amount) public onlyOwner {
        _updateTrust(account, amount);
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