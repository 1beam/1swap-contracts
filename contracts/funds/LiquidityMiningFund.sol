// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LiquidityMiningFund is Ownable {
    using SafeERC20 for IERC20;
    IERC20 public ONESWAP = IERC20(0x3516a7588C2E6FFA66C9507eF51853eb85d76e5B);
    uint256 public claimed_amount;

    mapping(address => bool) public pools;

    function currentBalance() public view returns (uint256) {
        return ONESWAP.balanceOf(address(this));
    }

    function transfer(address _poolAddress, uint256 _amount) external onlyOwner {
        require(_poolAddress != address(0), "Invalid address");
        require(_amount > 0, "invalid amount");
        require(_amount <= currentBalance(), "> balance");
        require(pools[_poolAddress], "Pool was not whitelisted");
        claimed_amount = claimed_amount + _amount;
        ONESWAP.safeTransfer(_poolAddress, _amount);
        emit FundTransfer(_poolAddress, _amount);
    }

    function addPool(address _poolAddress) external onlyOwner {
        require(!pools[_poolAddress], "Pool existed");
        pools[_poolAddress] = true;
        emit PoolAdded(_poolAddress);
    }

    function removePool(address _poolAddress) external onlyOwner {
        require(pools[_poolAddress], "Pool note existed");
        delete pools[_poolAddress];
        emit PoolRemoved(_poolAddress);
    }

    event FundTransfer(address indexed _receiver, uint256 _amount);
    event PoolAdded(address indexed _poolAddress);
    event PoolRemoved(address indexed _poolAddress);
}
