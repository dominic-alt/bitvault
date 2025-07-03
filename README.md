# BitVault Options Exchange

> A next-generation decentralized derivatives platform built on Stacks, enabling institutional-grade Bitcoin options trading with zero counterparty risk.

## Overview

BitVault revolutionizes Bitcoin derivatives by creating a trustless, permissionless options marketplace that combines traditional finance sophistication with DeFi innovation. Our protocol enables users to create, trade, and settle Bitcoin options contracts entirely on-chain, eliminating intermediaries while maintaining full capital efficiency.

## Key Features

- **Fully Collateralized Options** - Zero counterparty risk with automatic settlement
- **Dynamic Pricing** - Real-time market data integration for accurate valuations
- **Multi-Asset Support** - Various Bitcoin derivatives trading capabilities
- **Institutional Grade** - Built for high-frequency trading with enterprise security
- **Stacks Layer 2 Optimized** - Designed for scalability and compliance
- **Cross-Chain Ready** - Future-proof architecture for maximum liquidity

## System Overview

BitVault operates as a decentralized options exchange where users can create, buy, and exercise Bitcoin options contracts. The system is built on three core principles:

1. **Trustless Execution** - All trades are executed through smart contracts without intermediaries
2. **Full Collateralization** - Every option is backed by 100% collateral to eliminate default risk
3. **Transparent Pricing** - On-chain price feeds ensure fair and transparent option valuations

### Supported Option Types

- **Call Options** - Right to buy Bitcoin at a specific strike price
- **Put Options** - Right to sell Bitcoin at a specific strike price

## Contract Architecture

The BitVault smart contract is structured with several key components:

### Core Data Structures

```clarity
;; Option Contract Record
{
  writer: principal,      // Option creator/seller
  holder: principal,      // Option buyer/owner
  option-type: string,    // "CALL" or "PUT"
  strike-price: uint,     // Exercise price
  premium: uint,          // Option cost
  collateral: uint,       // Backing amount
  expiry: uint,           // Expiration block
  exercised: bool,        // Settlement status
  created-at: uint        // Creation timestamp
}
```

### Security Features

- **Access Control** - Principal-based authorization for all operations
- **Time Locks** - Minimum expiry periods to prevent flash loan attacks
- **Input Validation** - Comprehensive parameter checking and sanitization
- **Collateral Management** - Automated escrow and release mechanisms

## Data Flow

### Option Creation Flow

```
Writer → Deposits Collateral → Creates Option → Option Listed
```

### Option Trading Flow

```
Buyer → Pays Premium → Option Transferred → Writer Receives Payment
```

### Option Exercise Flow

```
Holder → Exercises Option → Price Check → Collateral Transfer → Settlement
```

### Option Expiry Flow

```
Block Height ≥ Expiry → Writer Reclaims Collateral → Option Closed
```

## API Reference

### Write Functions

#### `create-option`

Creates a new option contract with specified parameters.

**Parameters:**

- `sbtc-token`: SIP-010 token contract
- `option-type`: "CALL" or "PUT"
- `strike-price`: Exercise price (8 decimal precision)
- `premium`: Option cost
- `collateral`: Backing amount
- `expiry`: Expiration block height

**Returns:** `option-id` on success

#### `buy-option`

Purchases an existing option from the marketplace.

**Parameters:**

- `sbtc-token`: SIP-010 token contract
- `option-id`: Target option identifier

**Returns:** `true` on successful purchase

#### `exercise-option`

Exercises an owned option contract.

**Parameters:**

- `sbtc-token`: SIP-010 token contract
- `option-id`: Option to exercise

**Returns:** `true` on successful exercise

#### `expire-option`

Reclaims collateral from expired unexercised options.

**Parameters:**

- `sbtc-token`: SIP-010 token contract
- `option-id`: Expired option identifier

**Returns:** `true` on successful expiry

### Read Functions

#### `get-option`

Retrieves complete option data by ID.

#### `get-current-price`

Returns current Bitcoin price from oracle.

#### `get-contract-stats`

Returns platform statistics and metrics.

#### `get-user-balance`

Gets user balance from internal accounting.

## Error Codes

| Code | Description |
|------|-------------|
| u100 | Not authorized |
| u101 | Invalid amount |
| u102 | Option not found |
| u103 | Option expired |
| u104 | Insufficient balance |
| u105 | Invalid strike price |
| u106 | Invalid expiry |
| u107 | Already exercised |
| u108 | Invalid option type |
| u109 | Zero amount |
| u110 | Expiry too soon |
| u111 | Not expired |

## Usage Examples

### Creating a Call Option

```clarity
;; Create a call option with $55,000 strike price
(contract-call? .bitvault-options create-option 
  .sbtc-token 
  "CALL" 
  u5500000000000  ;; $55,000 strike
  u100000000      ;; 1 sBTC premium
  u100000000      ;; 1 sBTC collateral
  u1000)          ;; Expiry block
```

### Buying an Option

```clarity
;; Purchase option ID 1
(contract-call? .bitvault-options buy-option 
  .sbtc-token 
  u1)
```

### Exercising an Option

```clarity
;; Exercise owned option
(contract-call? .bitvault-options exercise-option 
  .sbtc-token 
  u1)
```

## Security Considerations

- **Collateral Requirements** - All options must be fully collateralized
- **Expiry Validation** - Minimum 24-hour expiry period enforced
- **Price Oracle** - Implement secure price feeds for production
- **Access Control** - Only authorized principals can perform operations
- **Reentrancy Protection** - Built-in safeguards against attack vectors

## Development Roadmap

- [ ] Price oracle integration
- [ ] Advanced option strategies (spreads, straddles)
- [ ] Liquidity mining rewards
- [ ] Cross-chain bridge compatibility
- [ ] Mobile application interface
- [ ] Institutional custody integration

## Contributing

We welcome contributions to BitVault! Please read our contributing guidelines and submit pull requests for review.