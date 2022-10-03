// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DummyERC20 is ERC20 {
    constructor() ERC20("DummyERC20", "D20") {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}