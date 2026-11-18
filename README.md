# Meridian Vault

A gas-optimized ERC4626 vault with multi-strategy yield aggregation.

## Overview

Allocates deposited assets across multiple DeFi yield strategies, automatically rebalancing to maximize risk-adjusted returns. Built on meridian-core for minimal gas overhead.

## Getting Started

```bash
git clone --recurse-submodules https://github.com/<org>/vault-protocol.git
cd vault-protocol
forge build
forge test
```

## Architecture

```
src/
├── Vault.sol              — Core ERC4626 vault
├── interfaces/
│   └── IVault.sol         — Vault interface
script/
├── Deploy.s.sol           — Deployment script
test/
├── Vault.t.sol            — Vault tests
lib/
├── meridian-core/         — Core library (ERC20, auth, utils)
```

## Deployments

| Network  | Address |
|----------|---------|
| Mainnet  | `0x...` |
| Arbitrum | `0x...` |
| Base     | `0x...` |

## Security

- Audit in progress
- Bug bounty coming soon

## License

MIT
