// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vault} from "../src/Vault.sol";
import {ERC20} from "meridian-core/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK", 18) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract VaultTest {
    Vault public vault;
    MockERC20 public token;

    function setUp() public {
        token = new MockERC20();
        vault = new Vault(
            ERC20(address(token)),
            "Meridian Vault",
            "mVAULT",
            type(uint256).max
        );
    }

    function test_deposit() public {
        token.mint(address(this), 1000e18);
        token.approve(address(vault), 100e18);
        uint256 shares = vault.deposit(100e18, address(this));

        require(shares == 100e18, "wrong shares");
        require(vault.balanceOf(address(this)) == 100e18, "wrong balance");
        require(vault.totalAssets() == 100e18, "wrong total");
    }

    function test_withdraw() public {
        token.mint(address(this), 1000e18);
        token.approve(address(vault), 100e18);
        vault.deposit(100e18, address(this));
        vault.withdraw(50e18, address(this), address(this));

        require(vault.balanceOf(address(this)) == 50e18, "wrong vault balance");
        require(token.balanceOf(address(this)) == 950e18, "wrong token balance");
    }

    function test_shareAccounting() public {
        token.mint(address(this), 1000e18);
        token.approve(address(vault), 100e18);
        vault.deposit(100e18, address(this));

        require(vault.convertToShares(100e18) == 100e18, "shares mismatch");
        require(vault.convertToAssets(100e18) == 100e18, "assets mismatch");
    }
}
