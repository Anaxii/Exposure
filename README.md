# Exposure | Asset and Liquidity Management

Contracts:

ExposureAsset.sol

```
/**
  *  @title Exposure Asset
  *  @author Exposure
  *  @notice Manages a single token for an ExposureBasket
  *   - Manager:
  *    # Adds vesting contracts for a token to ignore from the supply
  *   - Owner:
  *    # Authorizes transfers
  *    # Authorizes trades
  *  @dev Ownable `owner()` is an ExposureManager contract.
  *  @dev Manageable `manager()` is the XPSR DAO.
  *  @dev ExposureAsset contracts are deployed through ExposureBasket.
*/
```
ExposureManager.sol

```
/**
  *  @title Exposure Manager
  *  @author Exposure
  *  @notice Middleman for communication between ExposureBasket and ExposureAsset contracts
  *   - ExposureBasket:
  *    # Deploy new ExposureAsset contracts
  *    # Authorize buying, selling, or transferring tokens in an ExposureAsset contract
  *    # Adjust the percentage of tokens that was traded for an epoch
  *   - Manager:
  *    # Set token pairs.
  *    # Set on-chain price oracles.
  *   - Users:
  *    # Get ExposureAssets contracts addresses for a token
  *    # Read balances, prices, and market caps of a token
  *  @dev Ownable `owner()` is an ExposureBasket contract.
  *  @dev Manageable `manager()` is the XPSR DAO.
  *  @dev ExposureAsset contracts are deployed through this contract.
*/
```

ExposureBasket.sol

```
/**
  *  @title Exposure Basket
  *  @author Exposure
  *  @notice Main point of interaction for an individual Exposure Market Basket
  *   - Users can:
  *    # Mint basket tokens/shares in exchange for underlying assets
  *    # Redeem basket tokens/shares in exchange for underlying assets
  *    # Buy underlying assets in exchange for USDC during rebalances
  *    # Sell underlying assets in exchange for USDC during rebalances
  *    # Call rebalance steps
  *  @dev All admin functions are callable by the DAO and limited by Ownable
  *  @dev Exposure basket shares are represented as ERC20 tokens
*/
```
