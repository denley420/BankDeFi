// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DummyERC721 is ERC721 {
    constructor() ERC721("DummyERC721", "D721") {}

    function mint(address _to, uint256 _id) public {
        _mint(_to, _id);
    }
}



