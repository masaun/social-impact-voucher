//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

//@dev - Import the Union Finance V1 SDK contracts from union-v1-sdk
import { UnionVoucher } from "./union-v1-sdk/UnionVoucher.sol";
import { UnionBorrower } from "./union-v1-sdk/UnionBorrower.sol";
import { BaseUnionMember } from "./union-v1-sdk/BaseUnionMember.sol";


/**
 * @title - Social Impact Vouch contract
 */ 
contract SocialImpactVouch is Ownable, UnionVoucher, UnionBorrower {
    
    constructor(address marketRegistry, address unionToken, address token) BaseUnionMember(marketRegistry,unionToken,token) {
     
    }

}