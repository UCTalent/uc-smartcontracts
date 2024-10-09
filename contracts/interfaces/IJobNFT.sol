// SPDX-License-Identifier: BSD 3-Clause

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IJobNFT is IERC721Upgradeable {
  function mint(address _owner) external returns (uint256);
}
