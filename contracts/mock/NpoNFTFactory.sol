//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { NpoNFT } from "./NpoNFT.sol";

import { INpoNFT } from "../interfaces/INpoNFT.sol";
import { INpoNFTFactory } from "../interfaces/INpoNFTFactory.sol";

import { Events } from "../libraries/Events.sol";


/**
 * @title - The factory contract for creating NPO NFTs
 */ 
contract NpoNFTFactory is INpoNFTFactory { 

    address[] public npoNFTs;

    constructor() {
        //[TODO]: 
    }

    function createNewNpoNFT(address npoMember) public override returns (NpoNFT _npoNFT) {
        NpoNFT npoNFT = new NpoNFT(npoMember);
        npoNFTs.push(address(npoNFT));

        emit Events.NpoNFTCreated(npoNFT);

        return npoNFT;
    }

}