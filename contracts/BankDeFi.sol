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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyContract is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint public transactionFee;
    mapping(address => mapping(address => NFTDetails)) _NFTDetails;
    mapping(address => mapping(address => uint)) totalAmount;
    mapping(address => bool) public unlockedERC20Address;
    mapping(address => bool) public unlockedERC721Address;

    struct NFTDetails {
        uint[] nftId;
        uint totalNft;
        mapping(uint => bool) nftExist;
    }

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __Ownable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
        transactionFee = 0.001 ether;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    function depositERC20(address _tokenAddress, uint _amount) public virtual payable {
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
    }

    function withdrawERC20(address _tokenAddress, uint _amount) public {
        require(unlockedERC20Address[_msgSender()], "Your account is locked");
        require(
            getTokenBalance(_tokenAddress) >= _amount,
            "Not enough balance"
        );
        IERC20(_tokenAddress).transfer(_msgSender(), _amount);
        totalAmount[_msgSender()][_tokenAddress] -= _amount;
    }

    function getTokenBalance(address _tokenAddress) public view returns (uint) {
        return totalAmount[_msgSender()][_tokenAddress];
    }

    function addAdmin(address _admin) public onlyOwner {
        _grantRole(ADMIN_ROLE, _admin);
    }

    function removeAdmin(address _admin) public onlyOwner {
        _revokeRole(ADMIN_ROLE, _admin);
    }

    function unlockUserERC20(address _user, bool isUnlocked)
        public
        onlyRole(ADMIN_ROLE)
    {
        unlockedERC20Address[_user] = isUnlocked;
    }

    function unlockUserERC721(address _user, bool isUnlocked)
        public
        onlyRole(ADMIN_ROLE)
    {
        unlockedERC721Address[_user] = isUnlocked;
    }

    function depositERC721(address _contractAddress, uint _nftId)
        public
        payable
    {
        require(
            msg.value >= transactionFee,
            "Did not reach require amount of ether"
        );
        IERC721(_contractAddress).transferFrom(
            _msgSender(),
            address(this),
            _nftId
        );
        _NFTDetails[_msgSender()][_contractAddress].totalNft++;
        if (!_NFTDetails[_msgSender()][_contractAddress].nftExist[_nftId]) {
            _NFTDetails[_msgSender()][_contractAddress].nftExist[_nftId] = true;
            _NFTDetails[_msgSender()][_contractAddress].nftId.push(_nftId);
        }
    }

    function withdrawERC721(address _contractAddress, uint _nftId) public {
        require(unlockedERC721Address[_msgSender()], "Your account is locked");
        require(
            _NFTDetails[_msgSender()][_contractAddress].nftExist[_nftId],
            "You dont own this NFT"
        );
        IERC721(_contractAddress).transferFrom(
            address(this),
            _msgSender(),
            _nftId
        );
        _NFTDetails[_msgSender()][_contractAddress].nftExist[_nftId] = false;
        _NFTDetails[_msgSender()][_contractAddress].totalNft--;
    }

    function getNftBalance(address _contractAddress)
        public
        view
        returns (uint)
    {
        return _NFTDetails[_msgSender()][_contractAddress].totalNft;
    }
}
