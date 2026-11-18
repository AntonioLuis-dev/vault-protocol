// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "meridian-core/tokens/ERC20.sol";
import {SafeTransferLib} from "meridian-core/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "meridian-core/utils/FixedPointMathLib.sol";
import {Owned} from "meridian-core/auth/Owned.sol";
import {IVault} from "./interfaces/IVault.sol";

/// @title Meridian Vault
/// @notice Gas-optimized ERC4626 vault with multi-strategy yield aggregation
/// @author Meridian Finance
contract Vault is ERC20, Owned, IVault {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    ERC20 public immutable asset;
    uint256 public totalStrategyDebt;
    uint256 public depositLimit;

    mapping(address => StrategyParams) public strategies;

    struct StrategyParams {
        uint256 debtRatio;
        uint256 totalDebt;
        uint256 lastReport;
        bool active;
    }

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol,
        uint256 _depositLimit
    ) ERC20(_name, _symbol, _asset.decimals()) Owned(msg.sender) {
        asset = _asset;
        depositLimit = _depositLimit;
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this)) + totalStrategyDebt;
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        uint256 supply = totalSupply;
        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        uint256 supply = totalSupply;
        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        require(totalAssets() + assets <= depositLimit, "deposit limit");

        shares = convertToShares(assets);
        require(shares > 0, "zero shares");

        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(uint256 assets, address receiver, address owner_) external returns (uint256 shares) {
        shares = convertToShares(assets);

        if (msg.sender != owner_) {
            uint256 allowed = allowance[owner_][msg.sender];
            if (allowed != type(uint256).max) {
                allowance[owner_][msg.sender] = allowed - shares;
            }
        }

        _burn(owner_, shares);
        asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner_, assets, shares);
    }

    function addStrategy(address strategy, uint256 debtRatio) external onlyOwner {
        require(!strategies[strategy].active, "already active");
        strategies[strategy] = StrategyParams({
            debtRatio: debtRatio,
            totalDebt: 0,
            lastReport: block.timestamp,
            active: true
        });
        emit StrategyAdded(strategy, debtRatio);
    }

    function setDepositLimit(uint256 _limit) external onlyOwner {
        depositLimit = _limit;
    }
}
