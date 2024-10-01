# UCReferral DOCUMENTATION

Table of Contents
=================
* [Table of Contents](#table-of-contents)
   * [Write functions](#write-functions)
      * [Admin functions](#admin-functions)
         * [setConfig](#setconfig)
      * [User functions](#user-functions)
         * [createJob](#createjob)
         * [closeJob](#closejob)
         * [disputeJob](#disputejob)
         * [resolveDispute](#resolvedispute)
         * [completeJob](#completejob)
   * [Read functions](#read-functions)
         * [config](#config)
         * [jobs](#jobs)
   * [Events](#events)
         * [JobCreated](#jobcreated)
         * [JobClosed](#jobclosed)
         * [JobDisputed](#jobdisputed)
         * [JobCompleted](#jobcompleted)
         * [DisputeResolved](#disputeresolved)
         * [ConfigUpdated](#configupdated)
## Write functions
### Admin functions
#### setConfig
- purpose: 
- syntax: `setConfig(uint _ecosystemFeePercentage, uint _referralFeePercentage, uint _disputeFeePercentage, uint _baseReferalPercentage, uint _freezePeriod, address _treasury)`
- params:
  - `uint _ecosystemFeePercentage`: ecosystem fee percentage in decimal 3
  - `uint _referralFeePercentage`: referral fee percentage in decimal 3
  - `uint _disputeFeePercentage`: dispute fee percentage in decimal 3
  - `uint _baseReferalPercentage`: base referral fee percentage in decimal 3
  - `uint _freezePeriod`: the freeze period to hold fund when complete job
  - `address _treasury`: treasury address
- event:
  - [ConfigUpdated](#configupdated)
### User functions
#### createJob
- purpose:
- syntax: `createJob(bytes32 _jobId, uint _amount, uint _timestamp)`
- params:
  - `bytes32 _jobId`: the job Id
  - `uint _amount`: the bonus amount
  - `uint _timestamp`: timestamp
- event:
  - [JobCreated](#jobcreated)
#### closeJob
- purpose:
- syntax: `closeJob(bytes32 _jobId)`
- params:
  - `bytes32 _jobId`:
- event:
  - [JobClosed](#jobclosed)
#### disputeJob
- purpose:
- syntax: `disputeJob(bytes32 _jobId)`
- params:
  - `bytes32 _jobId`:
- event:
  - [JobDisputed](#jobdisputed)
#### resolveDispute
- purpose:
- syntax: `resolveDispute(bytes32 _jobId, bool _reverted)`
- params:
  - `bytes32 _jobId`:
  - `bool _reverted`:
- event:
  - [DisputeResolved](#disputeresolved)
#### completeJob
- purpose:
- syntax: `completeJob(bytes32 _jobIb)`
- params:
  - `bytes32 _jobIb`:
- event:
  - [JobCompleted](#jobcompleted)
## Read functions
#### config
- syntax: `config()`
- return: 
  - `uint _ecosystemFeePercentage`: ecosystem fee percentage in decimal 3
  - `uint _referralFeePercentage`: referral fee percentage in decimal 3
  - `uint _disputeFeePercentage`: dispute fee percentage in decimal 3
  - `uint _baseReferalPercentage`: base referral fee percentage in decimal 3
  - `uint _freezePeriod`: the freeze period to hold fund when complete job
  - `address _treasury`: treasury address
#### jobs
- syntax: `jobs(bytes32 _jobId)`
- params:
  - `bytes32 _jobId`: the job id
- return: 
    - `address creator`: creator address
    - `address talent`: talent address
    - `address referrer`: referrer address
    - `uint referalPercentage`: referral percentage in decimal 3
    - `uint amount`: bonus amount
    - `uint timestamp`: created timestamp
    - `uint closeTimestamp`: close timestamp
    - `uint disputeTimestamp;`: dispute timestamp
## Events
#### JobCreated
- function fired: [createJob](#createjob)
- syntax: `JobCreated(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp)`
- params:
  - `bytes32 _jobId`: the job Id
  - `address indexed creator`: creator address
  - `uint _amount`: the bonus amount
  - `uint _timestamp`: timestamp
#### JobClosed
- function fired: [closeJob](#closejob)
- syntax: `JobClosed(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp)`
- params:
  - `bytes32 _jobId`: the job Id
  - `address indexed creator`: creator address
  - `uint _amount`: the bonus amount
  - `uint _timestamp`: timestamp
#### JobDisputed
- function fired: [disputeJob](#disputejob)
- syntax: `JobDisputed(bytes32 indexed jobId, address indexed creator, uint amount, uint timestamp)`
- params:
  - `bytes32 _jobId`: the job Id
  - `address indexed creator`: creator address
  - `uint _amount`: the bonus amount
  - `uint _timestamp`: timestamp
#### JobCompleted
- function fired: [completeJob](#completejob)
- syntax: `JobCompleted(bytes32 indexed jobId, address indexed talent, uint amount, uint timestamp)`
- params:
  - `bytes32 _jobId`: the job Id
  - `address indexed talent`: talent address
  - `uint _amount`: the bonus amount
  - `uint _timestamp`: timestamp
#### DisputeResolved
- function fired: [resolveDispute](#resolvedispute)
- syntax: `DisputeResolved(bytes32 indexed jobId, bool reverted, uint timestamp)`
- params:
  - `bytes32 _jobId`: the job Id
  - `bool reverted`: reverted == true: refund bonus to creator
  - `uint _timestamp`: timestamp
#### ConfigUpdated
- function fired: [setConfig](#setconfig)
- syntax: `ConfigUpdated(uint ecosystemFeePercentage, uint referralFeePercentage, uint disputeFeePercentage, uint baseReferalPercentage, uint freezePeriod, address treasury)`
  - `uint _ecosystemFeePercentage`: ecosystem fee percentage in decimal 3
  - `uint _referralFeePercentage`: referral fee percentage in decimal 3
  - `uint _disputeFeePercentage`: dispute fee percentage in decimal 3
  - `uint _baseReferalPercentage`: base referral fee percentage in decimal 3
  - `uint _freezePeriod`: the freeze period to hold fund when complete job
  - `address _treasury`: treasury address
