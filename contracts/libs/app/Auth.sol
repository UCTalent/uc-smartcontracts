// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {

  address public owner;

  event OwnerUpdated(address indexed _newOwner);

  function __Auth_init(address _mn) internal onlyInitializing {
    owner = _mn;
  }

  modifier onlyOwner() {
    require(_isOwner(), "onlyOwner");
    _;
  }

  function updateOwner(address _newValue) external onlyOwner {
    require(_newValue != address(0x0));
    owner = _newValue;
    emit OwnerUpdated(_newValue);
  }

  function _isOwner() internal view returns (bool) {
    return msg.sender == owner;
  }
}