# SHRD - Omnichain Fungible Token

SHRD is an omnichain ERC20 token built with LayerZero's OFT (Omnichain Fungible Token) standard, enabling seamless token transfers across multiple chains.

## Features

- Cross-chain token transfers
- ERC20 standard compliance
- Voting capabilities
- Flash loan support
- Token vesting functionality

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd SHRD
```

2. Install dependencies:
```bash
forge install
```

3. Set up environment variables:
- Rename `.env.example` to `.env`
- Configure your environment variables:
```env
PRIVATE_KEY=your_private_key_here

# Sepolia Testnet RPCs
ETH_SEPOLIA_RPC_URL=your_eth_sepolia_rpc_url
BASE_SEPOLIA_RPC_URL=your_base_sepolia_rpc_url
ARB_SEPOLIA_RPC_URL=your_arb_sepolia_rpc_url

# Block explorer API keys
ETHERSCAN_API_KEY=your_etherscan_api_key
BASESCAN_API_KEY=your_basescan_api_key
ARBISCAN_API_KEY=your_arbiscan_api_key
```


