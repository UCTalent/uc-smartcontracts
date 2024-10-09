// SPDX-License-Identifier: BSD 3-Clause

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./abstract/Base.sol";
import "./interfaces/IJobNFT.sol";

contract UCReferral is Base {
  IBEP20 public usdtToken;

  enum Status {
    CREATED,
    DISPUTED,
    CLOSED,
    COMPLETED
  }

  struct Config {
    uint ecosystemFeePercentage;
    uint referralFeePercentage;
    uint disputeFeePercentage;
    uint baseReferalPercentage;
    uint freezePeriod;
    address treasury;
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
  }

  Config public config;
  IJobNFT public jobNFT;
  mapping (bytes32 => Job) public jobs;
  uint constant ONE_HUNDRED_DECIMAL3 = 100000;

  event JobCreated(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp);
  event JobClosed(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp);
  event JobDisputed(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp);
  event JobCompleted(bytes32 indexed jobId, address indexed talent, uint amount, uint timestamp);
  event DisputeResolved(bytes32 indexed jobId, bool reverted, uint timestamp);
  event ConfigUpdated(uint ecosystemFeePercentage, uint referralFeePercentage, uint disputeFeePercentage, uint baseReferalPercentage, uint freezePeriod, address treasury);
  
  function initialize(address _usdt, address _jobNFT) public initializer {
    __BaseContract_init(msg.sender);
    config.ecosystemFeePercentage = 10000;
    config.referralFeePercentage = 10000;
    config.disputeFeePercentage = 10000;
    config.baseReferalPercentage = 50000;
    config.freezePeriod = 7 days;
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
    emit JobCreated(_jobId, msg.sender, _amount, _timestamp);
  }

  function closeJob(bytes32 _jobId) external {
    Job storage job = jobs[_jobId];
    require(job.status == Status.CREATED, "UCReferral: not created");
    require(jobNFT.ownerOf(job.nftId) == msg.sender, "UCReferral: 401");
    job.status = Status.CLOSED;
    job.closeTimestamp = block.timestamp;
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
    require(job.disputeTimestamp + config.freezePeriod < block.timestamp, "UCReferral: dispute not ended");
    job.status = Status.COMPLETED;
    uint ecosystemFee = job.amount * config.ecosystemFeePercentage / ONE_HUNDRED_DECIMAL3;
    uint disputeFee = job.amount * config.disputeFeePercentage / ONE_HUNDRED_DECIMAL3;
    _transferToken(usdtToken, config.treasury, ecosystemFee + disputeFee);
    uint disputeAmount = job.amount - ecosystemFee - disputeFee;
    if (_reverted) {
      _transferToken(usdtToken, job.creator, disputeAmount);
    } else {
      uint referralFee = disputeAmount * config.referralFeePercentage / ONE_HUNDRED_DECIMAL3;
      _transferToken(usdtToken, job.talent, disputeAmount - referralFee);
      if (job.referrer == address(0)) {
        _transferToken(usdtToken, job.talent, referralFee);
      } else {
        _transferToken(usdtToken, job.referrer, referralFee);
      }
    }
    emit DisputeResolved(_jobId, _reverted, block.timestamp);
  }

  function completeJob(bytes32 _jobIb) external {
    Job storage job = jobs[_jobIb];
    require(job.status == Status.CLOSED, "UCReferral: not created");
    require(job.closeTimestamp + config.freezePeriod < block.timestamp, "UCReferral: freeze period not ended");
    job.status = Status.COMPLETED;
    uint ecosystemFee = job.amount * config.ecosystemFeePercentage / ONE_HUNDRED_DECIMAL3;
    _transferToken(usdtToken, config.treasury, ecosystemFee);
    uint referralFee = job.amount * config.referralFeePercentage / ONE_HUNDRED_DECIMAL3;
    uint talentAmount = job.amount - ecosystemFee - referralFee;
    _transferToken(usdtToken, job.talent, talentAmount);
    if (job.referrer == address(0)) {
      _transferToken(usdtToken, job.talent, referralFee);
    } else {
      _transferToken(usdtToken, job.referrer, referralFee);
    }
    emit JobCompleted(_jobIb, job.talent, job.amount, block.timestamp);
  }

  function setConfig(uint _ecosystemFeePercentage, uint _referralFeePercentage, uint _disputeFeePercentage, uint _baseReferalPercentage, uint _freezePeriod, address _treasury) external onlyOwner {
    config.ecosystemFeePercentage = _ecosystemFeePercentage;
    config.referralFeePercentage = _referralFeePercentage;
    config.disputeFeePercentage = _disputeFeePercentage;
    config.baseReferalPercentage = _baseReferalPercentage;
    config.freezePeriod = _freezePeriod;
    config.treasury = _treasury;
    emit ConfigUpdated(_ecosystemFeePercentage, _referralFeePercentage, _disputeFeePercentage, _baseReferalPercentage, _freezePeriod, _treasury);
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

  function _takeToken(IBEP20 _token, uint _amount) private {
    require(_token.allowance(msg.sender, address(this)) >= _amount, "UCReferral: allowance invalid");
    require(_token.balanceOf(msg.sender) >= _amount, "UCReferral: insufficient balance");
    _token.transferFrom(msg.sender, address(this), _amount);
  }
}