// SPDX-License-Identifier: BSD 3-Clause

import "../libs/app/Auth.sol";

pragma solidity 0.8.9;

abstract contract Base is Auth {
  function __BaseContract_init(address _owner) internal {
    __Auth_init(_owner);
  }
}