//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { SocialImpactVoucher } from "./SocialImpactVoucher.sol";


/**
 * @title - Social Impact Voucher Factory contract
 */ 
contract SocialImpactVoucherFactory {
    
    address[] public socialImpactVouchers;

    constructor() {
        //[TODO]: 
    }

    /**
     * @notice - Create a new SocialImpactVoucher contract
     */ 
    function createNewSocialImpactVoucher(address marketRegistry, address unionToken, address token, address nonProfitOrganization) public {
        SocialImpactVoucher socialImpactVoucher = new SocialImpactVoucher(marketRegistry, unionToken, token, nonProfitOrganization);
        address SOCIAL_IMPACT_VOUCHER = address(socialImpactVoucher);
        socialImpactVouchers.push(SOCIAL_IMPACT_VOUCHER);
    }

}