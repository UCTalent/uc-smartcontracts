// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

contract TokenAuth is Context {

  address internal backup;
  address internal owner;
  mapping (address => bool) public ecosystemAddresses;
  mapping (address => bool) public saleAddresses;
  mapping (address => uint) public advisorAddresses;
  address public marketingAddress;
  address public liquidityPool;
  address public treasuryAddress;

  uint constant public MAX_ADVISOR_ALLOCATION = 30e24;
  uint public advisorAllocated;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(
    address _owner,
    address _liquidityPool
  ) {
    owner = _owner;
    backup = _owner;
    liquidityPool = _liquidityPool;
  }

  modifier onlyOwner() {
    require(isOwner(), "onlyOwner");
    _;
  }

  modifier onlyBackup() {
    require(isBackup(), "onlyBackup");
    _;
  }

  modifier onlyEcosystemAddress() {
    require(ecosystemAddresses[_msgSender()], "TokenAuth: invalid caller");
    _;
  }

  modifier onlySaleContract() {
    require(saleAddresses[_msgSender()], "TokenAuth: invalid caller");
    _;
  }

  modifier onlyEcosystemContract() {
    require(ecosystemAddresses[_msgSender()], "TokenAuth: invalid caller");
    _;
  }

  modifier onlyMarketingAddress() {
    require(_msgSender() == marketingAddress, "TokenAuth: invalid caller");
    _;
  }

  modifier onlyliquidityPool() {
    require(_msgSender() == liquidityPool, "TokenAuth: invalid caller");
    _;
  }

  modifier onlyTreasuryAddress() {
    require(_msgSender() == treasuryAddress, "TokenAuth: invalid caller");
    _;
  }

  modifier onlyAdvisorAddress() {
    require(advisorAddresses[_msgSender()] > 0, "TokenAuth: invalid caller");
    _;
  }

  function transferOwnership(address _newOwner) external onlyBackup {
    require(_newOwner != address(0), "TokenAuth: invalid new owner");
    owner = _newOwner;
    emit OwnershipTransferred(_msgSender(), _newOwner);
  }

  function updateBackup(address _newBackup) external onlyBackup {
    require(_newBackup != address(0), "TokenAuth: invalid new backup");
    backup = _newBackup;
  }

  function setEcosystemAddress(address _ecosystemAddress, bool _status) external onlyOwner {
    require(_ecosystemAddress != address(0), "TokenAuth: ecosystem address is the zero address");
    ecosystemAddresses[_ecosystemAddress] = _status;
  }

  function setSaleAddress(address _address, bool _status) external onlyOwner {
    require(_address != address(0), "TokenAuth: sale address is the zero address");
    saleAddresses[_address] = _status;
  }

  function setMarketingAddress(address _address) external onlyOwner {
    require(_address != address(0), "TokenAuth: marketing address is the zero address");
    marketingAddress = _address;
  }

  function setliquidityPool(address _address) external onlyOwner {
    require(_address != address(0), "TokenAuth: liquidity address is the zero address");
    liquidityPool = _address;
  }

  function setTreasuryAddress(address _address) external onlyOwner {
    require(_address != address(0), "TokenAuth: treasury address is the zero address");
    treasuryAddress = _address;
  }

  function setAdvisorAddress(address _address, uint _allocation) public virtual onlyOwner {
    require(_address != address(0), "TokenAuth: advisor address is the zero address");
    require(advisorAllocated + _allocation <= MAX_ADVISOR_ALLOCATION, "Invalid amount");
    advisorAddresses[_address] = _allocation;
    advisorAllocated = advisorAllocated + _allocation;
  }

  function updateAdvisorAddress(address _oldAddress, address _newAddress) public virtual onlyOwner {
    require(_oldAddress != address(0), "TokenAuth: advisor address is the zero address");
    advisorAddresses[_newAddress] = advisorAddresses[_oldAddress];
    delete advisorAddresses[_oldAddress];
  }

  function isOwner() public view returns (bool) {
    return _msgSender() == owner;
  }

  function isBackup() public view returns (bool) {
    return _msgSender() == backup;
  }
}
