// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./libs/app/NFTAuth.sol";
import "./libs/app/ArrayUtil.sol";

contract JobNFT is NFTAuth, ERC721Upgradeable {
  using ArrayUtil for uint[];
  uint public totalSupply;
  uint private tokenCounter;

  function initialize(
    string calldata _name,
    string calldata _symbol
  ) public initializer {
    NFTAuth.__NFTAuth_init(msg.sender);
    ERC721Upgradeable.__ERC721_init(_name, _symbol);
  }

  function mint(address _owner) external onlyMintRight returns (uint256) {
    _mint(_owner, ++tokenCounter);
    return tokenCounter;
  }

  function burn(uint256 tokenId) public virtual {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
    _burn(tokenId);
  }

  function _beforeTokenTransfer(address _from, address _to, uint _tokenId) internal override {
    if (_from == address(0)) {
      totalSupply++;
    }
    if (_to == address(0)) {
      totalSupply--;
    }
    _tokenId;
  }
}
