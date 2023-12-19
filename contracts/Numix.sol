// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Numix is ERC20, ERC20Burnable, ERC20Pausable, Ownable {

    address public manager;

    event TokensMinted(address to, uint256 amount);
    event TokensBurned(address account, uint256 amount);

    modifier onlyOwnerOrManager() {
        require((owner() == msg.sender) || (manager == msg.sender), "Caller needs to be Owner or Manager");
        _;
    }

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        manager = msg.sender;
    }

    function pause() public onlyOwnerOrManager {
        _pause();
    }

    function unpause() public onlyOwnerOrManager {
        _unpause();
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function mint(address to, uint256 amount) public onlyOwnerOrManager {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }


    function burn(uint256 amount) public override {
        super.burn(amount);
        emit TokensBurned(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
        emit TokensBurned(account, amount);
    }

}