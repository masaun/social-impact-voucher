//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
//import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

//@dev - Import the Union Finance V1 SDK contracts from union-v1-sdk
import { UnionVoucher } from "./union-v1-sdk/UnionVoucher.sol";
import { UnionBorrower } from "./union-v1-sdk/UnionBorrower.sol";
import { BaseUnionMember } from "./union-v1-sdk/BaseUnionMember.sol";


/**
 * @title - Social Impact Vouch contract
 */ 
contract SocialImpactVouch is AccessControl, UnionVoucher, UnionBorrower {

    //@dev - Roles
    bytes32 public constant NON_PROFIT_ORGANIZATION_ROLE = keccak256("NON_PROFIT_ORGANIZATION_ROLE");

    /**
     * @param token - Underlying token address
     */ 
    constructor(address marketRegistry, address unionToken, address token, address nonProfitOrganization) BaseUnionMember(marketRegistry, unionToken, token) {
       _setupRole(NON_PROFIT_ORGANIZATION_ROLE, nonProfitOrganization);
    }

    /**
     * @notice - Register a new member
     */ 
    function registerMember() public onlyRole(NON_PROFIT_ORGANIZATION_ROLE) {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(msg.sender, address(this), newMemberFee);
        _registerMember();
    }

}