// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Numix.sol";
import "hardhat/console.sol";


contract NumixController is Ownable {
    using Strings for uint256;


    struct TransactionRecord {
        uint256 index; // will start from 1
        uint256 tokensMinted;
        address[] users;
        uint256[] userShares;
        uint256[] userTokens;
    }
    uint256 public transactionIndex = 1; // will start from 1
    address public numixAddress;
    address public manager;

    mapping(string => TransactionRecord) public transactionRecord;

    event TransactionRecorded(uint256 index, string id, uint256 tokensMinted, address[] users,  uint256[] userShares, uint256[] userTokens);

    modifier onlyOwnerOrManager() {
        require((owner() == msg.sender) || (manager == msg.sender), "Caller needs to be Owner or Manager");
        _;
    }

    constructor(address _numixERC20Address){
        numixAddress = _numixERC20Address;
        manager = msg.sender;
    }
    //mapping(address => uint256) public 

    // _id is the combination of project_id_remix_id
    // _tokensMinted should be with 10 decimals
    // _shares should be with denominated of 10000. So for 10% it should be 1000, for 6.6% it should 660
    function tokenMinted(string memory _id, uint256 _tokensMinted, address[] memory _users, uint256[] memory _userShares) public onlyOwnerOrManager {
        require(_tokensMinted > 0, "Zero Tokens");
        require(_users.length == _userShares.length, "User and Shares list mismatch");
        require(numixAddress != address(0), "Numix address is null");

        uint256 totalShares = 0;
        uint256 totalSharesAmount = 0;
        uint256[] memory _sharesAmount = new uint256[](_userShares.length);
        for (uint256 i = 0; i < _userShares.length; i++) {
            totalShares +=_userShares[i];
            _sharesAmount[i] = _tokensMinted * _userShares[i] / 10000;
            totalSharesAmount += _sharesAmount[i];
        }
        require(totalShares == 10000, "Total Shares are not 100%");
        require(totalSharesAmount == _tokensMinted, "Total Minted not equal to total shares amount");

        // Mint tokens
        Numix numix = Numix(numixAddress);
        for (uint256 i = 0; i < _userShares.length; i++) {
            numix.mint(_users[i], _sharesAmount[i]);
        }
        //

        //string memory uniqueId = string(abi.encodePacked(_nftAddress, _tokenId));
        //string memory uniqueId = string(abi.encodePacked("a", "b"));
        TransactionRecord storage data = transactionRecord[_id];

        //require(data.nftAddress == address(0), "TransactionRecord already exists");
        require(data.index == 0, "TransactionRecord already exists");

        data.index = transactionIndex;
        data.tokensMinted = _tokensMinted;
        data.users = _users;
        data.userShares = _userShares;
        data.userTokens = _sharesAmount;

        emit TransactionRecorded(transactionIndex,_id, _tokensMinted, _users, _userShares, _sharesAmount);
        transactionIndex++;
    }

    // amount will be in 18 decimal points
    // in progress >>>>>.
    function burnTokens(address account, uint256 amount) public onlyOwnerOrManager{
        //require(_tokensMinted > 0, "Zero Tokens");
        //require(_users.length == _userShares.length, "User and Shares list mismatch");
        require(numixAddress != address(0), "Numix address is null");

        Numix numix = Numix(numixAddress);
        numix.burnFrom(account, amount);

    }

    function updateNumixAddress(address _numixAddress) public onlyOwnerOrManager {
        numixAddress = _numixAddress;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

}