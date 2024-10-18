// SPDX-License-Identifier: BSD 3-Clause

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./abstract/Base.sol";
import "./interfaces/IJobNFT.sol";

contract UCReferral is Base, EIP712Upgradeable {
  IBEP20 public usdtToken;

  enum Status {
    CREATED,
    DISPUTED,
    CLOSED,
    COMPLETED
  }

  enum Result {
    PENDING,
    SUCCESS,
    FAIL
  }

  struct Config {
    uint ecosystemFeePercentage;
    uint referralFeePercentage;
    uint disputeFeePercentage;
    uint baseReferalPercentage;
    uint freezePeriod;
    address treasury;
    address serverSigner;
  }

  struct Job {
    address creator;
    address talent;
    address referrer;
    uint referalPercentage;
    uint amount;
    uint timestamp;
    uint closeTimestamp;
    uint disputeTimestamp;
    uint nftId;
    Status status;
    Result result;
  }

  uint constant ONE_HUNDRED_DECIMAL3 = 100000;
  Config public config;
  IJobNFT public jobNFT;
  mapping (bytes32 => Job) public jobs;
  mapping (address => uint) public nonce;

  event JobCreated(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp);
  event JobClosed(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp);
  event JobDisputed(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp);
  event JobCompleted(bytes32 indexed jobId, address indexed talent, uint amount, uint timestamp);
  event DisputeResolved(bytes32 indexed jobId, bool reverted, uint timestamp);
  event ConfigUpdated(uint ecosystemFeePercentage, uint referralFeePercentage, uint disputeFeePercentage, uint baseReferalPercentage, uint freezePeriod, address treasury, address serverSigner); 
  
  function initialize(
    string memory _name,
    string memory _version,
    address _usdt, 
    address _jobNFT,
    address _owner) public initializer {
    __BaseContract_init(_owner);
    EIP712Upgradeable.__EIP712_init(_name, _version);
    config.ecosystemFeePercentage = 10000;
    config.referralFeePercentage = 10000;
    config.disputeFeePercentage = 10000;
    config.baseReferalPercentage = 50000;
    config.freezePeriod = 7 days;
    config.serverSigner = _owner;
    usdtToken = IBEP20(_usdt);
    jobNFT = IJobNFT(_jobNFT);
  }

  function createJob(bytes32 _jobId, uint _amount, uint _timestamp) external {
    Job storage job = jobs[_jobId];
    require(job.creator == address(0), "UCReferral: job already exists");
    _takeToken(usdtToken, _amount);
    job.creator = msg.sender;
    job.amount = _amount;
    job.timestamp = _timestamp;
    job.status = Status.CREATED;
    job.nftId = jobNFT.mint(msg.sender);
    job.result = Result.PENDING;
    emit JobCreated(_jobId, msg.sender, _amount, _timestamp);
  }

  function closeJob(
    bytes32 _jobId, 
    bool _success,
    address _talent, 
    address _referrer, 
    uint _refPercentage, 
    uint _applyTimestamp, 
    uint _refTimestamp, 
    bytes memory _signature) external {
    Job storage job = jobs[_jobId];
    require(job.status == Status.CREATED, "UCReferral: not created");
    require(jobNFT.ownerOf(job.nftId) == msg.sender, "UCReferral: 401");
    _validateCloseJobSignature(_jobId, _success, _talent, _referrer, _refPercentage, _applyTimestamp, _refTimestamp, _signature);
    job.status = Status.CLOSED;
    job.closeTimestamp = block.timestamp;
    job.talent = _talent;
    job.referrer = _referrer;
    job.referalPercentage = _refPercentage;
    job.result = _success ? Result.SUCCESS : Result.FAIL;
    emit JobClosed(_jobId, msg.sender, job.amount, block.timestamp);
  }

  function disputeJob(bytes32 _jobId) external {
    Job storage job = jobs[_jobId];
    require(job.status == Status.CLOSED, "UCReferral: not closed");
    require(msg.sender == job.talent || msg.sender == job.referrer, "UCReferral: 401");
    job.status = Status.DISPUTED;
    job.disputeTimestamp = block.timestamp;
    emit JobDisputed(_jobId, msg.sender, job.amount, block.timestamp);
  }

  function resolveDispute(bytes32 _jobId, bool _reverted) external onlyOwner {
    Job storage job = jobs[_jobId];
    require(job.status == Status.DISPUTED, "UCReferral: not disputed");
    job.status = Status.COMPLETED;
    uint ecosystemFee = job.amount * config.ecosystemFeePercentage / ONE_HUNDRED_DECIMAL3;
    uint disputeFee = job.amount * config.disputeFeePercentage / ONE_HUNDRED_DECIMAL3;
    _transferToken(usdtToken, config.treasury, ecosystemFee + disputeFee);
    uint disputeAmount = job.amount - ecosystemFee - disputeFee;
    if (_reverted) {
      _transferToken(usdtToken, job.creator, disputeAmount);
    } else {
      uint referralFee = _calculateReferralFee(disputeAmount, job.referalPercentage);
      _transferToken(usdtToken, job.talent, disputeAmount - referralFee);
      if (job.referrer == address(0)) {
        _transferToken(usdtToken, job.talent, referralFee);
      } else {
        _transferToken(usdtToken, job.referrer, referralFee);
      }
    }
    emit DisputeResolved(_jobId, _reverted, block.timestamp);
  }

  function _calculateReferralFee(uint _amount, uint _refPercentage) private view returns (uint) {
    return _amount * (_refPercentage > 0 ? _refPercentage : config.baseReferalPercentage) / ONE_HUNDRED_DECIMAL3;
  }

  function completeJob(bytes32 _jobId) external {
    Job storage job = jobs[_jobId];
    require(job.status == Status.CLOSED, "UCReferral: not closed");
    require(job.closeTimestamp + config.freezePeriod < block.timestamp, "UCReferral: freeze period not ended");
    job.status = Status.COMPLETED;
    uint ecosystemFee = job.amount * config.ecosystemFeePercentage / ONE_HUNDRED_DECIMAL3;
    _transferToken(usdtToken, config.treasury, ecosystemFee);
    if (job.result == Result.SUCCESS) {
      require(msg.sender == job.talent || msg.sender == job.referrer, "UCReferral: 401");
      uint referralFee = _calculateReferralFee(job.amount, job.referalPercentage);
      uint talentAmount = job.amount - ecosystemFee - referralFee;
      _transferToken(usdtToken, job.talent, talentAmount);
      if (job.referrer == address(0)) {
        _transferToken(usdtToken, job.talent, referralFee);
      } else {
        _transferToken(usdtToken, job.referrer, referralFee);
      }
    } else {
      require(jobNFT.ownerOf(job.nftId) == msg.sender, "UCReferral: 401");
      _transferToken(usdtToken, job.creator, job.amount - ecosystemFee);
    }
    emit JobCompleted(_jobId, job.talent, job.amount, block.timestamp);
  }

  function setConfig(
    uint _ecosystemFeePercentage, 
    uint _referralFeePercentage, 
    uint _disputeFeePercentage, 
    uint _baseReferalPercentage, 
    uint _freezePeriod,
    address _treasury,
    address _serverSinger) external onlyOwner {
    config.ecosystemFeePercentage = _ecosystemFeePercentage;
    config.referralFeePercentage = _referralFeePercentage;
    config.disputeFeePercentage = _disputeFeePercentage;
    config.baseReferalPercentage = _baseReferalPercentage;
    config.freezePeriod = _freezePeriod;
    config.treasury = _treasury;
    config.serverSigner = _serverSinger;
    emit ConfigUpdated(_ecosystemFeePercentage, _referralFeePercentage, _disputeFeePercentage, _baseReferalPercentage, _freezePeriod, _treasury, _serverSinger);
  }

  function setUsdtToken(address _usdtToken) external onlyOwner {
    usdtToken = IBEP20(_usdtToken);
  }

  function setJobNFT(address _jobNFT) external onlyOwner {
    jobNFT = IJobNFT(_jobNFT);
  }

  function _transferToken(IBEP20 _token, address _to, uint _amount) private {
    _token.transfer(_to, _amount);
  }

  function _validateCloseJobSignature(
    bytes32 _jobId, 
    bool _success, 
    address _talent, 
    address _referrer, 
    uint _refPercentage, 
    uint _applyTimestamp, 
    uint _refTimestamp, 
    bytes memory _signature) private {
    bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
        keccak256("CloseJob(bytes32 jobId,bool success,address talent,address referrer,uint256 refPercentage,uint256 applyTimestamp,uint256 refTimestamp,uint256 nonce)"),
        _jobId,
        _success,
        _talent,
        _referrer,
        _refPercentage,
        _applyTimestamp,
        _refTimestamp,
        nonce[msg.sender]
      )));
    nonce[msg.sender]++;
    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == config.serverSigner, "MessageVerifier: invalid signature");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature");
  }

  function _takeToken(IBEP20 _token, uint _amount) private {
    require(_token.allowance(msg.sender, address(this)) >= _amount, "UCReferral: allowance invalid");
    require(_token.balanceOf(msg.sender) >= _amount, "UCReferral: insufficient balance");
    _token.transferFrom(msg.sender, address(this), _amount);
  }
}