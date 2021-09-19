// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TreasuryFund is Ownable {
    using SafeERC20 for IERC20;
    IERC20 public ONESWAP = IERC20(0x3516a7588C2E6FFA66C9507eF51853eb85d76e5B);

    uint256 private constant DURATION = 2 * 365 * 24 * 3600; // 2 years
    uint256 private constant START = 1632229200; // Sep 21st 2021 - 01:00PM UTC
    uint256 private constant ALLOCATION = 100_000_000 ether;
    uint256 private constant ONESWAP_PER_SECOND = ALLOCATION / DURATION;

    uint256 public claimed_amount;

    function currentBalance() public view returns (uint256) {
        return ONESWAP.balanceOf(address(this));
    }

    function vestedBalance() public view returns (uint256) {
        if (block.timestamp <= START) {
            return 0;
        }
        return ONESWAP_PER_SECOND * (block.timestamp - START);
    }

    function claimable() public view returns (uint256) {
        return vestedBalance() - claimed_amount;
    }

    function transfer(address _receiver, uint256 _amount) public onlyOwner {
        require(_receiver != address(0), "Invalid address");
        require(_amount > 0, "invalid amount");
        require(_amount <= currentBalance(), "> balance");
        require(claimed_amount + _amount <= vestedBalance(), "> vestedAmount");

        claimed_amount = claimed_amount + _amount;
        ONESWAP.safeTransfer(_receiver, _amount);
    }
}
