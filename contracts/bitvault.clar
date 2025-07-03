;; BitVault Options Exchange
;;
;; Summary:
;; A next-generation decentralized derivatives platform built on Stacks,
;; enabling institutional-grade Bitcoin options trading with zero counterparty risk.
;;
;; Description:
;; BitVault revolutionizes Bitcoin derivatives by creating a trustless, 
;; permissionless options marketplace that combines traditional finance 
;; sophistication with DeFi innovation. Our protocol enables users to 
;; create, trade, and settle Bitcoin options contracts entirely on-chain,
;; eliminating intermediaries while maintaining full capital efficiency.
;;
;; Key Features:
;; - Fully collateralized options with automatic settlement
;; - Dynamic pricing mechanisms with real-time market data
;; - Multi-asset support for various Bitcoin derivatives
;; - Gasless trading through meta-transactions
;; - Institutional-grade risk management protocols
;; - Cross-chain compatibility for maximum liquidity
;;
;; Built for Stacks Layer 2 compliance and optimized for high-frequency
;; trading scenarios while maintaining decentralization principles.

;; Define the SIP-010 fungible token trait interface
(define-trait ft-trait (
  (transfer
    (uint principal principal (optional (buff 34)))
    (response bool uint)
  )
  (get-balance
    (principal)
    (response uint uint)
  )
  (get-total-supply
    ()
    (response uint uint)
  )
  (get-name
    ()
    (response (string-ascii 32) uint)
  )
  (get-symbol
    ()
    (response (string-ascii 32) uint)
  )
  (get-decimals
    ()
    (response uint uint)
  )
  (get-token-uri
    ()
    (response (optional (string-utf8 256)) uint)
  )
))

;; CONSTANTS & ERROR CODES

(define-constant CONTRACT-OWNER tx-sender)

;; Error codes for better debugging and user experience
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-OPTION-NOT-FOUND (err u102))
(define-constant ERR-OPTION-EXPIRED (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-INVALID-STRIKE-PRICE (err u105))
(define-constant ERR-INVALID-EXPIRY (err u106))
(define-constant ERR-ALREADY-EXERCISED (err u107))
(define-constant ERR-INVALID-OPTION-TYPE (err u108))
(define-constant ERR-ZERO-AMOUNT (err u109))
(define-constant ERR-EXPIRY-TOO-SOON (err u110))
(define-constant ERR-NOT-EXPIRED (err u111))

;; Precision and timing constants
(define-constant PRECISION u100000000) ;; 8 decimal places for BTC precision
(define-constant MIN-EXPIRY-BLOCKS u144) ;; Minimum 24 hours (144 blocks at 10min/block)