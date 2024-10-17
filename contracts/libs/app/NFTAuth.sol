// SPDX-License-Identifier: GPL

pragma solidity 0.8.9;

import "./Auth.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract NFTAuth is Auth, ContextUpgradeable {
  mapping(address => bool) public mintAble;
  mapping(address => bool) public transferable;
  mapping (address => bool) public waitingList;

  function __NFTAuth_init(address _owner) internal onlyInitializing {
    Auth.__Auth_init(_owner);
  }

  modifier onlyMintRight() {
    require(_isMintRight() || _isOwner(), "NFTAuth: Only mint right");
    _;
  }

  modifier onlyTransferable() {
    require(_isTransferAble() || _isOwner(), "NFTAuth: Only transferAble");
    _;
  }

  function  _isMintRight() internal view returns (bool) {
    return mintAble[_msgSender()];
  }

  function _isTransferAble() internal view returns (bool) {
    return transferable[_msgSender()];
  }

  function updateMintAble(address _address, bool _mintAble) external onlyOwner {
    require(_address != address(0), "NFTAuth: Address invalid");
    mintAble[_address] = _mintAble;
  }

  function updateTransferable(address _address, bool _transferable) external onlyOwner {
    require(_address != address(0), "NFTAuth: Address invalid");
    transferable[_address] = _transferable;
  }

}
