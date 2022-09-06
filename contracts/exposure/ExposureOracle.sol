//pragma solidity =0.6.6;
//
//import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
//import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
//import '@uniswap/lib/contracts/libraries/FixedPoint.sol';
//import './v2library.sol';
//
//interface IERC20 {
//    /**
//     * @dev Returns the amount of tokens in existence.
//     */
//    function totalSupply() external view returns (uint256);
//
//    /**
//     * @dev Returns the amount of tokens owned by `account`.
//     */
//    function balanceOf(address account) external view returns (uint256);
//
//    /**
//     * @dev Moves `amount` tokens from the caller's account to `recipient`.
//     *
//     * Returns a boolean value indicating whether the operation succeeded.
//     *
//     * Emits a {Transfer} event.
//     */
//    function transfer(address recipient, uint256 amount) external returns (bool);
//
//    /**
//     * @dev Returns the remaining number of tokens that `spender` will be
//     * allowed to spend on behalf of `owner` through {transferFrom}. This is
//     * zero by default.
//     *
//     * This value changes when {approve} or {transferFrom} are called.
//     */
//    function allowance(address owner, address spender) external view returns (uint256);
//
//    /**
//     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
//     *
//     * Returns a boolean value indicating whether the operation succeeded.
//     *
//     * IMPORTANT: Beware that changing an allowance with this method brings the risk
//     * that someone may use both the old and the new allowance by unfortunate
//     * transaction ordering. One possible solution to mitigate this race
//     * condition is to first reduce the spender's allowance to 0 and set the
//     * desired value afterwards:
//     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
//     *
//     * Emits an {Approval} event.
//     */
//    function approve(address spender, uint256 amount) external returns (bool);
//
//    /**
//     * @dev Moves `amount` tokens from `sender` to `recipient` using the
//     * allowance mechanism. `amount` is then deducted from the caller's
//     * allowance.
//     *
//     * Returns a boolean value indicating whether the operation succeeded.
//     *
//     * Emits a {Transfer} event.
//     */
//    function transferFrom(
//        address sender,
//        address recipient,
//        uint256 amount
//    ) external returns (bool);
//
//    /**
//     * @dev Emitted when `value` tokens are moved from one account (`from`) to
//     * another (`to`).
//     *
//     * Note that `value` may be zero.
//     */
//    event Transfer(address indexed from, address indexed to, uint256 value);
//
//    /**
//     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
//     * a call to {approve}. `value` is the new allowance.
//     */
//    function decimals() external view returns (uint8);
//
//    event Approval(address indexed owner, address indexed spender, uint256 value);
//}
//
//
//
//contract ExampleSlidingWindowOracle {
//    using FixedPoint for *;
//    using SafeMath for uint;
//
//    struct Observation {
//        uint timestamp;
//        uint price0Cumulative;
//        uint price1Cumulative;
//    }
//
//    address public immutable factory;
//    // the desired amount of time over which the moving average should be computed, e.g. 24 hours
//    uint public immutable windowSize;
//    // the number of observations stored for each pair, i.e. how many price observations are stored for the window.
//    // as granularity increases from 1, more frequent updates are needed, but moving averages become more precise.
//    // averages are computed over intervals with sizes in the range:
//    //   [windowSize - (windowSize / granularity) * 2, windowSize]
//    // e.g. if the window size is 24 hours, and the granularity is 24, the oracle will return the average price for
//    //   the period:
//    //   [now - [22 hours, 24 hours], now]
//    uint8 public immutable granularity;
//    // this is redundant with granularity and windowSize, but stored for gas savings & informational purposes.
//    uint public immutable periodSize;
//
//    // mapping from pair address to a list of price observations of that pair
//    mapping(address => Observation[]) public pairObservations;
//
//    constructor(address factory_) public {
//        uint8 granularity_ = 2;
//        uint windowSize_ = 5 minutes;
//        require(granularity_ > 1, 'SlidingWindowOracle: GRANULARITY');
//        require(
//            (periodSize = windowSize_ / granularity_) * granularity_ == windowSize_,
//            'SlidingWindowOracle: WINDOW_NOT_EVENLY_DIVISIBLE'
//        );
//        factory = factory_;
//        windowSize = windowSize_;
//        granularity = granularity_;
//    }
//
//    // returns the index of the observation corresponding to the given timestamp
//    function observationIndexOf(uint timestamp) public view returns (uint8 index) {
//        uint epochPeriod = timestamp / periodSize;
//        return uint8(epochPeriod % granularity);
//    }
//
//    // returns the observation from the oldest epoch (at the beginning of the window) relative to the current time
//    function getFirstObservationInWindow(address pair) private view returns (Observation storage firstObservation) {
//        uint8 observationIndex = observationIndexOf(block.timestamp);
//        // no overflow issue. if observationIndex + 1 overflows, result is still zero.
//        uint8 firstObservationIndex = (observationIndex + 1) % granularity;
//        firstObservation = pairObservations[pair][firstObservationIndex];
//    }
//
//    // update the cumulative price for the observation at the current timestamp. each observation is updated at most
//    // once per epoch period.
//    function update(address tokenA, address tokenB) external {
//        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
//
//        // populate the array with empty observations (first call only)
//        for (uint i = pairObservations[pair].length; i < granularity; i++) {
//            pairObservations[pair].push();
//        }
//
//        // get the observation for the current period
//        uint8 observationIndex = observationIndexOf(block.timestamp);
//        Observation storage observation = pairObservations[pair][observationIndex];
//
//        // we only want to commit updates once per period (i.e. windowSize / granularity)
//        uint timeElapsed = block.timestamp - observation.timestamp;
//        if (timeElapsed > periodSize) {
//            (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
//            observation.timestamp = block.timestamp;
//            observation.price0Cumulative = price0Cumulative;
//            observation.price1Cumulative = price1Cumulative;
//        }
//    }
//
//    // given the cumulative prices of the start and end of a period, and the length of the period, compute the average
//    // price in terms of how much amount out is received for the amount in
//    function computeAmountOut(
//        uint priceCumulativeStart, uint priceCumulativeEnd,
//        uint timeElapsed, uint amountIn
//    ) private pure returns (uint amountOut) {
//        // overflow is desired.
//        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
//            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
//        );
//        amountOut = priceAverage.mul(amountIn).decode144();
//    }
//
//    // returns the amount out corresponding to the amount in for a given token using the moving average over the time
//    // range [now - [windowSize, windowSize - periodSize * 2], now]
//    // update must have been called for the bucket corresponding to timestamp `now - windowSize`
//    function consult(address tokenIn, address tokenOut) external view returns (uint amountOut) {
//        address pair = IUniswapV2Factory(factory).getPair(tokenIn, tokenOut);
//        Observation storage firstObservation = getFirstObservationInWindow(pair);
//
//        uint timeElapsed = block.timestamp - firstObservation.timestamp;
//        // require(timeElapsed <= windowSize, 'SlidingWindowOracle: MISSING_HISTORICAL_OBSERVATION');
//        if (timeElapsed <= windowSize || timeElapsed >= windowSize - periodSize * 2) {
//            return fallbackPrice(pair, tokenIn, tokenOut);
//        }
//        // should never happen.
//        // require(timeElapsed >= windowSize - periodSize * 2, 'SlidingWindowOracle: UNEXPECTED_TIME_ELAPSED');
//
//        (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
//        (address token0,) = UniswapV2Library.sortTokens(tokenIn, tokenOut);
//
//        if (token0 == tokenIn) {
//            return computeAmountOut(firstObservation.price0Cumulative, price0Cumulative, timeElapsed, 1e18);
//        } else {
//            return computeAmountOut(firstObservation.price1Cumulative, price1Cumulative, timeElapsed, 1e18);
//        }
//    }
//
//    function fallbackPrice(address pair, address tokenIn, address tokenOut) internal view returns (uint amountOut) {
//        (uint256 reserve0, uint256 reserve1, uint32 _timestamp) = IUniswapV2Pair(pair).getReserves();
//        uint256 _decimal0 = IERC20(IUniswapV2Pair(pair).token0()).decimals();
//        uint256 _decimal1 = IERC20(IUniswapV2Pair(pair).token1()).decimals();
//        if (_decimal0 != 18) {
//            reserve0 = reserve0 * (10**(18-_decimal0));
//        }
//        if (_decimal1 != 18) {
//            reserve1 = reserve1 * (10**(18-_decimal1));
//        }
//        uint price = 0;
//        if (IUniswapV2Pair(pair).token0() == tokenIn) {
//            price = reserve0 * 1e18 / reserve1;
//        } else {
//            price = reserve1 * 1e18 / reserve0;
//        }
//        return price;
//    }
//}
