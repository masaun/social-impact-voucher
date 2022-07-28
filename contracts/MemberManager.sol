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
 * @title - The member manager contract
 */ 
contract MemberManager is AccessControl, UnionVoucher, UnionBorrower{
    uint256 public vouchAmount;
    IERC721 public npoNFT;

    //@dev - Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant NON_PROFIT_ORGANIZATION_ROLE = keccak256("NON_PROFIT_ORGANIZATION_ROLE");

    constructor(address marketRegistry, address unionToken, address token) BaseUnionMember(marketRegistry,unionToken,token){
        //[TODO]: 
    }

    /**
     * @notice - Become a member as a NPO
     * @dev - A NPO member receive a NPO-NFT
     */ 
    function registerMemberAsNPO() public {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(msg.sender, address(this), newMemberFee);
        _registerMember();

        //[TODO]: @dev - A NPO-NFT is created (minted) in the NpoNFTFactory contract
        IERC721 npoNFT;  // [TODO]: Assign a NPO-NFT contract instance

        //@dev - A NPO-NFT is distributed into the NPO member's wallet address
        uint tokenId = 0;
        npoNFT.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /**
     * @notice - Become a member as a supporter
     */ 
    function registerMemberAsSupporter() public {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(msg.sender, address(this), newMemberFee);
        _registerMember();
    }

}