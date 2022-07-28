//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { NpoNFT } from "./NpoNFT.sol";


/**
 * @title - The factory contract for creating NPO NFTs
 */ 
contract NpoNFTFactory { 

    address[] public npoNFTs;

    constructor() {
        //[TODO]: 
    }

    function createNewNpoNFT() public returns (bool) {
        NpoNFT npoNFT = new NpoNFT();
        npoNFTs.push(address(npoNFT));
    }

}