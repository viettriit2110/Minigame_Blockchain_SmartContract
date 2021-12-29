// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract Game is Ownable, ERC20Burnable {
  constructor() ERC20("Game", "GE") {
    _mint(msg.sender, 1000000000*10**18);
  }

  function randomModulus( uint mod) external view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % mod ;
  }
}
