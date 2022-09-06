//import "./utils/Ownable.sol";
//
//
//interface IExposureBasket {
//    function mint(uint256 amount, address to) external;
//    function WETH() external pure returns (address);
//    function getTokenPortions(uint256 _epoch, address _token) external view returns (uint256);
//
//    function addLiquidity(
//        address tokenA,
//        address tokenB,
//        uint amountADesired,
//        uint amountBDesired,
//        uint amountAMin,
//        uint amountBMin,
//        address to,
//        uint deadline
//    ) external returns (uint amountA, uint amountB, uint liquidity);
//    function addLiquidityETH(
//        address token,
//        uint amountTokenDesired,
//        uint amountTokenMin,
//        uint amountETHMin,
//        address to,
//        uint deadline
//    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
//}
//
//
//contract AutoMint is Ownable {
//
//    address wavax;
//    address router;
//    address[] tokens;
//    address exposureAddress;
//
//    // check if secondary market gets you more shares
//
//
//    constructor(address _wavax, address _router, address _exposureAddress, address _owner) {
//        wavax = _wavax;
//        transferOwnership(_owner);
//        router = _router;
//        exposureAddress = _exposureAddress;
//    }
//
//    function CreateShares(address[] memory _tokenList, uint256 epoch) payable external {
//        IExposureBasket exposure = IExposureBasket(exposureAddress);
//        WAVAX(payable(wavax)).deposit{value: msg.value}();
//        require(IERC20(wavax).balanceOf(address(this)) >= msg.value);
//
//        uint256[] memory portions = new uint256[](_tokenList.length);
//        uint256[] memory costs = new uint256[](_tokenList.length);
//        address[] memory path = new address[](2);
//        uint256 avaxCostForTokens;
//        for (uint i; i < _tokenList.length; i++) {
//            uint256 portion = exposure.getTokenPortions(epoch, _tokenList[i]);
//            portions[i] = portion;
//            path[0] = address(wavax);
//            path[1] = _tokenList[i];
//            uint[] memory amounts = IUniswapV2Router01(router).getAmountsIn(portion, path);
//            avaxCostForTokens = avaxCostForTokens + amounts[0];
//            costs[i] = amounts[0];
//        }
//
//        uint256 numberOfShares = (msg.value * 1e18 / avaxCostForTokens) * (9995 * 1e14) / 1e18;
//        for (uint i; i < portions.length; i++) {
//            IERC20(wavax).approve(router, costs[i] * numberOfShares / 1e18);
//            path[0] = address(wavax);
//            path[1] = _tokenList[i];
//            IUniswapV2Router01(router).swapExactTokensForTokens(costs[i] * numberOfShares / 1e18, 1, path, address(this), block.timestamp + 40 seconds);
//        }
//
//        uint256 newShares = ~uint256(0);
//        for (uint i; i < portions.length; i++) {
//            uint256 bal = IERC20(_tokenList[i]).balanceOf(address(this));
//            uint256 maxAmount = bal * 1e18 / portions[i];
//            if (maxAmount < newShares)
//                newShares = maxAmount;
//        }
//
//        for (uint i; i < portions.length; i++) {
//            IERC20(_tokenList[i]).approve(exposureAddress, (portions[i] * newShares / 1e18) + 1);
//        }
//        newShares = newShares * (9995 * 1e14) / 1e18;
//        exposure.mint(newShares, msg.sender);
//    }
//
//    function drain(address[] memory _tokenList) public onlyOwner {
//        uint256 balance = address(this).balance;
//        if (balance > 0) {
//            payable(owner()).transfer(balance);
//        }
//        for (uint8 i = 0; i < _tokenList.length; i++) {
//            uint256 amount = IERC20(_tokenList[i]).balanceOf(address(this));
//            if (amount > 0) {
//                IERC20(_tokenList[i]).transfer(owner(), amount);
//            }
//
//        }
//    }
//}
