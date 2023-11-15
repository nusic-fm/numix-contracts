// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import "hardhat/console.sol";


contract NusicClips is ERC721, Pausable, Ownable, ERC2981, ReentrancyGuard {
    using Strings for uint256;

    // Numix 
    // 33
    uint256 public constant MAX_SUPPLY = 33;
    
    uint256 public constant MINT_PER_ADDR = 1; 

    string public defaultURI = "";
    string private baseURI;

    mapping(uint256 => string) private _tokenURIs;

    uint256 public totalSupply;

    bool public publicSaleLive = true;

    uint256 public price = 0.0009 ether;
    address public manager;
    address public treasuryAddress;

    event PublicSaleMinted(address sender, address indexed to, string uuid, uint256 tokenId);
    event ReserveTokenMinted(address sender, address indexed to, string uuid, uint256 tokenId);

    modifier onlyOwnerOrManager() {
        require((owner() == msg.sender) || (manager == msg.sender), "Caller needs to be Owner or Manager");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        manager = 0x07C920eA4A1aa50c8bE40c910d7c4981D135272B;
        treasuryAddress = msg.sender;
        _setDefaultRoyalty(owner(), 500);
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata _baseuri) public onlyOwnerOrManager {
		baseURI = _baseuri;
	}

    function setDefaultRI(string calldata _defaultURI) public onlyOwnerOrManager {
		defaultURI = _defaultURI;
	}

    function togglePublicSaleLive() public onlyOwnerOrManager {
        publicSaleLive = !publicSaleLive;
    }

    function setPrice(uint256 newPrice) public onlyOwnerOrManager {
        require(newPrice > 0, "Price can not be zero");
        price = newPrice;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwnerOrManager {
        treasuryAddress = _treasuryAddress;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exists");
        string memory _tokenURI = _tokenURIs[tokenId];
        return bytes(_tokenURI).length > 0 ? _tokenURI : defaultURI;
    }

    function mint(string memory _uuid, string memory _tokenURI) public onlyOwnerOrManager whenNotPaused nonReentrant{
        require(publicSaleLive, "Sale Not Active"); // Sale should be active
        require(totalSupply < MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        
        totalSupply++;
        _safeMint(treasuryAddress, totalSupply);
        _tokenURIs[totalSupply] = _tokenURI;
        
        emit PublicSaleMinted(msg.sender, treasuryAddress, _uuid, totalSupply);
    }

    function mintTo(address user, string memory _uuid, string memory _tokenURI) public onlyOwnerOrManager whenNotPaused nonReentrant{
        require(publicSaleLive, "Sale Not Active"); // Sale should be active
        require(totalSupply < MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        
        totalSupply++;
        _safeMint(user, totalSupply);
        _tokenURIs[totalSupply] = _tokenURI;
        
        emit PublicSaleMinted(msg.sender, user, _uuid, totalSupply);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981)
        returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return
            ERC721.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner nonReentrant{
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function pause() public onlyOwner nonReentrant {
        _pause();
    }

    function unpause() public onlyOwner nonReentrant {
        _unpause();
    }

    function withdraw() public onlyOwner nonReentrant{
        require(treasuryAddress != address(0),"Fund Owner is NULL");
        (bool sent1, ) = treasuryAddress.call{value: address(this).balance}("");
        require(sent1, "Failed to withdraw");
    }
}