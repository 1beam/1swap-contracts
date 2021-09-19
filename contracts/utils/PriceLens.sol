// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IUniswapV2Pair.sol";

contract PriceLens {
    uint256 public constant PRECISION = 1e18;

    function consultUniswapV2LPToken(
        IUniswapV2Pair lpToken,
        address token0Route,
        address token1Route,
        address chainlinkAddress0,
        address chainlinkAddress1
    ) external view returns (uint256) {
        address token0 = lpToken.token0();
        address token1 = lpToken.token1();

        uint256 token0Part = calculatePartOfLP(lpToken, token0, token0Route);
        uint256 token1Part = calculatePartOfLP(lpToken, token1, token1Route);

        token0Part = getChainlinkPrice(chainlinkAddress0, token0Part);
        token1Part = getChainlinkPrice(chainlinkAddress1, token1Part);
        uint256 totalSupply = lpToken.totalSupply();
        uint256 decimals = lpToken.decimals();

        uint256 totalAmount = token0Part + token1Part;
        return (totalAmount * 10**decimals) / totalSupply;
    }

    /**
     * calculate token price from series of Uniswap pair and chainlink price feed.
     * Once swap route is empty
     * @param token address of token to consult
     * @param pair swap route to get price
     * @param chainlinkAddress chainlink price feed
     */
    function consultToken(
        address token,
        address pair,
        address chainlinkAddress
    ) public view returns (uint256) {
        require(pair != address(0) || chainlinkAddress != address(0), "route empty");
        uint256 amountOut = consultTokenToToken(token, pair);

        if (chainlinkAddress == address(0)) {
            return amountOut;
        }

        return getChainlinkPrice(chainlinkAddress, amountOut);
    }

    // internal function
    function consultTokenToToken(address tokenIn, address pairAddress) internal view returns (uint256) {
        address tokenOut = address(0);

        if (pairAddress == address(0)) {
            return PRECISION;
        }

        uint256 amountIn = 10**ERC20(tokenIn).decimals();
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

        uint256 amountOut;
        if (tokenIn == pair.token0()) {
            tokenOut = pair.token1();
            amountOut = getAmountOut(amountIn, reserve0, reserve1);
        } else {
            assert(tokenIn == pair.token1());
            tokenOut = pair.token0();
            amountOut = getAmountOut(amountIn, reserve1, reserve0);
        }

        uint8 tokenOutDecimals = ERC20(tokenOut).decimals();
        return (amountOut * PRECISION) / 10**tokenOutDecimals;
    }

    // UniswapV2Libarary.getAmountOut
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }

    function getChainlinkPrice(address _priceFeedAddress, uint256 _amountIn) internal view returns (uint256) {
        assert(_priceFeedAddress != address(0));
        AggregatorV3Interface _priceFeed = AggregatorV3Interface(_priceFeedAddress);
        (, int256 _price, , , ) = _priceFeed.latestRoundData();
        uint8 _decimals = _priceFeed.decimals();
        return (uint256(_price) * _amountIn) / (10**_decimals);
    }

    function calculatePartOfLP(
        IUniswapV2Pair lpToken,
        address underlyingAddress,
        address token0Route
    ) internal view returns (uint256) {
        ERC20 underlying = ERC20(underlyingAddress);
        uint256 decimals = underlying.decimals();
        uint256 balance = underlying.balanceOf(address(lpToken));
        uint256 price = consultTokenToToken(address(underlying), token0Route);
        return (balance * price) / 10**decimals;
    }
}
