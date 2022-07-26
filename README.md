# Social Impact Vouch🎫 built on Union Finance

## Installation
```
yarn
```
```
yarn compile
```

<br>

## Test
- Unit Test of SocialImpactVouch.sol
```
yarn test:SocialImpactVouch
```

<br>

- Unit Test of union-v1-sdk
```
yarn test:union-v1-sdk
```

<br>

## Resources
- EthCC Hack🇫🇷2022: https://ethcchack2022.devpost.com/

<br>

- Union Finance📈
  - SCs：https://github.com/unioncredit
    - Union Protocol V1 SDK：https://github.com/unioncredit/union-v1-sdk
    - Deployed-addresses：https://docs.union.finance/developers/overview

  - Voucher Example
    https://docs.union.finance/developers/union-sdk

  - Discord：https://discord.com/channels/983106014637355089/998970729947222096/999003941608095854

  - Key Protocol activities
https://docs.union.finance/protocol-overview/plain-english-overview

  - Use cases
https://docs.union.finance/protocol-overview/plain-english-overview

  - What does Union do that wasn’t previously possible?
https://docs.union.finance/protocol-overview/master


  - Union Finance 🛠 Masters of Credit:Building Smart Contracts that can Borrow and Lend without Collateral
https://youtu.be/h5Eynrw9EC4
  ( https://github.com/masaun/DApps_Truffle_Ethereum_Projects/issues/605#issuecomment-1178891273 )


<hr>

# Union SDK

[![npm version](https://badge.fury.io/js/@unioncredit%2Fv1-sdk.svg)](https://badge.fury.io/js/@unioncredit%2Fv1-sdk)

A library to help developers build own contracts that interact with [Union protocol](https://union.finance).

## Structure

- [BaseUnionMember](./contracts/BaseUnionMember.sol) - has the basic functions of Union member.
- [UnionBorrower](./contracts/UnionBorrower.sol) - implements all the functions of a Union member that can borrower from other members.
- [UnionVoucher](./contracts/UnionVoucher.sol) - implements all the functions of Union member that can vouch for other members.

## Getting Started

### Installation

```
npm install @unioncredit/v1-sdk
```

### Imports

```solidity
import "@unioncredit/v1-sdk/contracts/BaseUnionMember.sol";
import "@unioncredit/v1-sdk/contracts/UnionVoucher.sol";
import "@unioncredit/v1-sdk/contracts/UnionBorrower.sol";
```

### Example Borrower

An example implementation of a contract that is a Union member. Once registered this contract would be able to
borrow DAI and use it to buy [OSQTH](https://www.opyn.co/).

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@unioncredit/v1-sdk/contracts/UnionBorrower.sol";

/**
 * @notice A UnionMember that borrows DAI to go long on OSQTH
 */
contract SqueethWithFriends is UnionBorrower {
  address public dai;
  
  constructor(address _dai) {
    dai = _dai;
  }
  
  function borrowAndSqueeth(uint256 _amountInDai) external {
    _borrow(_amountInDai);
    _investInSqueeth(_amountInDai);
  }
  
  function sellAndRepay(uint _amountInSqueeth) external {
    _sellSqueeth(_amountInSqueeth);
    uint balance = IERC20(dai).balanceOf(address(this));
    _repayBorrow(balance);
  }
  
  function _investInSqueeth(uint256 _amountInDai) internal {
    // buy OSQTH with DAI
  }
  
  function _sellSqueeth(uint256 _amountInSqueeth) internal {
    // sell OSQTH for DAI
  }
}
```

### Example Voucher

An example implementation of a contract that is a Union member. Once registered this contract would be able to
vouch for [frankfrank](https://opensea.io/collection/frankfrank) holders.

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@unioncredit/v1-sdk/contracts/UnionVoucher.sol";

/**
 * @notice A UnionMember that vouches for holders of frankfrank
 */
contract FrankFrankFriends is UnionVoucher {
  uint256 public vouchAmount;
  IERC721 public frank;
  
  constructor(uint _vouchAmount, IERC721 _frank) {
    vouchAmount = _vouchAmount;
    frank = _frank;
  }
  
  function stake() external {
    uint balance = IERC20(dai).balanceOf(address(this));
    _stake(balance);
  }
  
  function vouchForFrankFrank(address holder) external {
    require(frank.balanceOf(holder) > 0, "!holder");
    _updateTrust(holder, vouchAmount);
  }
  
  function cancelPaperHands(address holder) external {
    require(frank.balanceOf(holder) <= 0, "!paper hands");
    _cancelVouch(holder);
  }
}
```
