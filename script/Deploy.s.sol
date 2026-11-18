// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vault} from "../src/Vault.sol";
import {ERC20} from "meridian-core/tokens/ERC20.sol";

contract DeployVault {
    function run(address weth) external returns (address) {
        Vault vault = new Vault(
            ERC20(weth),
            "Meridian WETH Vault",
            "mWETH",
            10_000 ether
        );
        return address(vault);
    }
}
