;; DAO Treasury Management Contract
;; Handles proposals, voting, and treasury management

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u101))
(define-constant ERR-INSUFFICIENT-FUNDS (err u102))
(define-constant ERR-ALREADY-VOTED (err u103))
(define-constant ERR-PROPOSAL-EXPIRED (err u104))
(define-constant ERR-INVALID-WEIGHT (err u105))
(define-constant ERR-INVALID-TITLE (err u106))
(define-constant ERR-INVALID-DESCRIPTION (err u107))
(define-constant ERR-INVALID-AMOUNT (err u108))
(define-constant ERR-INVALID-RECIPIENT (err u109))
(define-constant ERR-EMPTY-TITLE (err u110))
(define-constant ERR-EMPTY-DESCRIPTION (err u111))
(define-constant ERR-ZERO-AMOUNT (err u112))

(define-constant VOTING_PERIOD u144) ;; ~24 hours in blocks
(define-constant MIN_PROPOSAL_AMOUNT u1000000) ;; Minimum proposal amount in STX
(define-constant MAX_MEMBER_WEIGHT u1000000) ;; Maximum weight a member can have
(define-constant MIN_MEMBER_WEIGHT u1) ;; Minimum weight a member can have


;; Define trait for staking pool contracts
(define-trait staking-pool-trait
    (
        (stake (uint) (response bool uint))
        (unstake (uint) (response bool uint))
        (get-staked-balance (principal) (response uint uint))
    )
)


;; Data Maps
(define-map proposals
    uint
    {
        proposer: principal,
        title: (string-ascii 50),
        description: (string-ascii 500),
        amount: uint,
        recipient: principal,
        start-block: uint,
        yes-votes: uint,
        no-votes: uint,
        executed: bool
    }
)

(define-map votes
    {proposal-id: uint, voter: principal}
    bool
)

(define-map member-weights
    principal
    uint
)

;; Data Variables
(define-data-var proposal-count uint u0)
(define-data-var dao-owner principal tx-sender)
(define-data-var total-members uint u0)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-member-weight (member principal))
    (default-to u0 (map-get? member-weights member))
)

(define-read-only (has-voted (proposal-id uint) (voter principal))
    (is-some (map-get? votes {proposal-id: proposal-id, voter: voter}))
)
