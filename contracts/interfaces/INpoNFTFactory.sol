// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import { INpoNFT } from "./INpoNFT.sol";
import { NpoNFT } from "../mock/NpoNFT.sol";

import { DataTypes } from '../libraries/DataTypes.sol';


interface INpoNFTFactory {

    function createNewNpoNFT(address npoMember) external returns (NpoNFT _npoNFT);

    event NpoNFTCreated(
        NpoNFT npoNFT
    );

}