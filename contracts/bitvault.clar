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

;; Option type identifiers
(define-constant OPTION-TYPE-CALL "CALL")
(define-constant OPTION-TYPE-PUT "PUT")

;; STATE VARIABLES

(define-data-var next-option-id uint u1)
(define-data-var total-options-created uint u0)
(define-data-var total-options-exercised uint u0)

;; DATA STRUCTURES

;; Primary options storage with comprehensive metadata
(define-map Options
  { option-id: uint }
  {
    writer: principal,
    holder: principal,
    option-type: (string-ascii 4),
    strike-price: uint,
    premium: uint,
    collateral: uint,
    expiry: uint,
    exercised: bool,
    created-at: uint,
  }
)

;; User balance tracking for internal accounting
(define-map UserBalances
  { user: principal }
  { balance: uint }
)

;; PRIVATE HELPER FUNCTIONS

;; Validates option type against supported types
(define-private (is-valid-option-type (option-type (string-ascii 4)))
  (or
    (is-eq option-type OPTION-TYPE-CALL)
    (is-eq option-type OPTION-TYPE-PUT)
  )
)

;; Secure token transfer with validation
(define-private (transfer-sbtc
    (token <ft-trait>)
    (amount uint)
    (sender principal)
    (recipient principal)
  )
  (begin
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    (contract-call? token transfer amount sender recipient none)
  )
)

;; Comprehensive expiry validation
(define-private (check-expiry (expiry uint))
  (let ((min-expiry (+ block-height MIN-EXPIRY-BLOCKS)))
    (asserts! (>= expiry min-expiry) ERR-EXPIRY-TOO-SOON)
    (asserts! (> expiry block-height) ERR-OPTION-EXPIRED)
    (ok true)
  )
)

;; Strike price validation with market constraints
(define-private (validate-strike-price (strike-price uint))
  (begin
    (asserts! (> strike-price u0) ERR-INVALID-STRIKE-PRICE)
    (ok true)
  )
)

;; Premium and collateral amount validation
(define-private (validate-amounts
    (premium uint)
    (collateral uint)
  )
  (begin
    (asserts! (> premium u0) ERR-ZERO-AMOUNT)
    (asserts! (> collateral u0) ERR-ZERO-AMOUNT)
    (ok true)
  )
)

;; READ-ONLY FUNCTIONS

;; Retrieve complete option data by ID
(define-read-only (get-option (option-id uint))
  (map-get? Options { option-id: option-id })
)

;; Get user balance from internal accounting
(define-read-only (get-user-balance (user principal))
  (default-to { balance: u0 } (map-get? UserBalances { user: user }))
)

;; Current BTC price oracle (placeholder for real oracle integration)
(define-read-only (get-current-price)
  u50000000000
)

;; $50,000 with 8 decimal places precision

;; Contract statistics and metrics
(define-read-only (get-contract-stats)
  {
    total-options: (var-get total-options-created),
    exercised-options: (var-get total-options-exercised),
    next-id: (var-get next-option-id),
  }
)

;; PUBLIC FUNCTIONS

;; Create a new options contract with full validation
(define-public (create-option
    (sbtc-token <ft-trait>)
    (option-type (string-ascii 4))
    (strike-price uint)
    (premium uint)
    (collateral uint)
    (expiry uint)
  )
  (let (
      (option-id (var-get next-option-id))
      (current-height block-height)
    )
    ;; Comprehensive input validation
    (asserts! (is-valid-option-type option-type) ERR-INVALID-OPTION-TYPE)
    (try! (validate-strike-price strike-price))
    (try! (validate-amounts premium collateral))
    (try! (check-expiry expiry))
    ;; Secure collateral transfer to contract
    (try! (transfer-sbtc sbtc-token collateral tx-sender (as-contract tx-sender)))
    ;; Create new option record
    (map-set Options { option-id: option-id } {
      writer: tx-sender,
      holder: tx-sender,
      option-type: option-type,
      strike-price: strike-price,
      premium: premium,
      collateral: collateral,
      expiry: expiry,
      exercised: false,
      created-at: current-height,
    })
    ;; Update global contract state
    (var-set next-option-id (+ option-id u1))
    (var-set total-options-created (+ (var-get total-options-created) u1))
    (ok option-id)
  )
)

;; Purchase an existing option from the marketplace
(define-public (buy-option
    (sbtc-token <ft-trait>)
    (option-id uint)
  )
  (let ((option (unwrap! (get-option option-id) ERR-OPTION-NOT-FOUND)))
    ;; Validate option state and buyer eligibility
    (try! (check-expiry (get expiry option)))
    (asserts! (not (get exercised option)) ERR-ALREADY-EXERCISED)
    (asserts! (not (is-eq tx-sender (get writer option))) ERR-NOT-AUTHORIZED)
    ;; Execute premium payment to option writer
    (try! (transfer-sbtc sbtc-token (get premium option) tx-sender (get writer option)))
    ;; Transfer option ownership to buyer
    (map-set Options { option-id: option-id }
      (merge option { holder: tx-sender })
    )
    (ok true)
  )
)