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

import { NpoNFT } from "./mock/NpoNFT.sol";
import { NpoNFTFactory } from "./mock/NpoNFTFactory.sol";


/**
 * @title - The member registry contract
 */ 
contract MemberRegistry is AccessControl, UnionVoucher, UnionBorrower {
    uint256 public vouchAmount;

    IERC721 public npoNFT;
    NpoNFTFactory public npoNFTFactory;

    //@dev - Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant NON_PROFIT_ORGANIZATION_ROLE = keccak256("NON_PROFIT_ORGANIZATION_ROLE");

    constructor(address marketRegistry, address unionToken, address token, NpoNFTFactory _npoNFTFactory) BaseUnionMember(marketRegistry, unionToken, token) {
        npoNFTFactory = _npoNFTFactory;
    }

    /**
     * @notice - Become a member as a NPO
     * @dev - A NPO member receive a NPO-NFT
     */
    function registerMemberAsNPO() public {
        address newNpoMember = msg.sender;
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(newNpoMember, address(this), newMemberFee);
        _registerMember();  //[Error]: "<UnrecognizedContract>.<unknown> (0x49c910ba694789b58f53bff80633f90b8631c195)"

        //@dev - A NPO-NFT is created (minted) to a new NPO member's wallet address in the NpoNFTFactory contract
        NpoNFT npoNFT = npoNFTFactory.createNewNpoNFT(newNpoMember);

        //@dev - A NPO-NFT is distributed into the NPO member's wallet address
        uint tokenId = 0;
        npoNFT.safeTransferFrom(address(this), newNpoMember, tokenId);
    }

    /**
     * @notice - Become a member as a supporter
     */ 
    function registerMemberAsSupporter() public {
        address newSupporterMember = msg.sender;
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(newSupporterMember, address(this), newMemberFee);
        _registerMember();  //[Error]: "<UnrecognizedContract>.<unknown> (0x49c910ba694789b58f53bff80633f90b8631c195)"
    }

}