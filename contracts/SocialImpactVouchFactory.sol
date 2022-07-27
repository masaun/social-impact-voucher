//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { SocialImpactVouch } from "./SocialImpactVouch.sol";


/**
 * @title - Social Impact Vouch Factory contract
 */ 
contract SocialImpactVouchFactory {
    
    address[] public socialImpactVouchs;

    constructor() {
        //[TODO]: 
    }

    /**
     * @notice - Create a new SocialImpactVouch contract
     */ 
    function createNewSocialImpactVouch(address marketRegistry, address unionToken, address token, address nonProfitOrganization) public {
        SocialImpactVouch socialImpactVouch = new SocialImpactVouch(marketRegistry, unionToken, token, nonProfitOrganization);
        address SOCIAL_IMPACT_VOUCH = address(socialImpactVouch);
        socialImpactVouchs.push(SOCIAL_IMPACT_VOUCH);
    }

}