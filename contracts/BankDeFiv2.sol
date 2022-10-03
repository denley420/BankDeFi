// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
Create a Bank - Upgradeable contracts using UUPS OZ

- Deposit and lock ERC721
- Deposit and lock ERC20
- Every deposit has an initial transaction fee of .001 ETH
- Add a transaction fee setter and getter
- ERC721 and ERC20 withdraw is only allowed if ADMIN unlocks them for certain users, 
- ADMIN is different from contract owner

- Upgrade Bank Contract after deployment
- Contract should be upgradable by users with UPGRADERS_ROLE
- Allow ERC1155 deposit and withdraw, withdraw logic is the same as ERC721 and ERC20
- Add an ETH recipient setter and getter, 
- ETH withdrawal after upgrade is allowed for recipient only

- EOA only for deposit and withdraw
- Implement a meta-transaction feature where the withdrawal of TOKENS will be requested by the msg.sender and executed by the Bank Contract.
- Use Chainlink keeper, set schedule for ETH withdrawal (for testing, set it to 15 secs)
*/
import "./BankDeFi.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyContractv2 is MyContract {
    
    function depositERC20(address _tokenAddress, uint _amount) public payable virtual override {
        require(
            msg.value >= transactionFee,
            "Did not reach require amount of ether"
        );
        IERC20(_tokenAddress).transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        totalAmount[_msgSender()][_tokenAddress] += _amount;
        console.log("test");
    }

        function depositERC1155(address _contractAddress, uint _nftId, uint _totalAmount)
        public
        payable
    {
        require(
            msg.value >= transactionFee,
            "Did not reach require amount of ether"
        );
        IERC1155(_contractAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _nftId,
            _totalAmount,
            ""
        );

        _NFTDetails[_msgSender()][_contractAddress].totalNft++;
        if (!_NFTDetails[_msgSender()][_contractAddress].nftExist[_nftId]) {
            _NFTDetails[_msgSender()][_contractAddress].nftExist[_nftId] = true;
            _NFTDetails[_msgSender()][_contractAddress].nftId.push(_nftId);
        }
    }

}