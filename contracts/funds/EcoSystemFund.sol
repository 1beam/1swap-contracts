// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract EcoSystemFund is Ownable {
    using SafeERC20 for IERC20;
    IERC20 public ONESWAP = IERC20(0x3516a7588C2E6FFA66C9507eF51853eb85d76e5B);
    uint256 public claimed_amount;

    function currentBalance() public view returns (uint256) {
        return ONESWAP.balanceOf(address(this));
    }

    function transfer(address _receiver, uint256 _amount) external onlyOwner {
        require(_receiver != address(0), "Invalid address");
        require(_amount > 0, "invalid amount");
        require(_amount <= currentBalance(), "> balance");
        claimed_amount = claimed_amount + _amount;
        ONESWAP.safeTransfer(_receiver, _amount);
        emit FundClaimed(_receiver, _amount);
    }

    event FundClaimed(address indexed _receiver, uint256 _amount);
}
