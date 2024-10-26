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

;; Data validation functions
(define-private (is-valid-weight (weight uint))
    (and 
        (>= weight MIN_MEMBER_WEIGHT)
        (<= weight MAX_MEMBER_WEIGHT)
    )
)

(define-private (is-valid-title (title (string-ascii 50)))
    (and
        (not (is-eq title ""))
        (<= (len title) u50)
    )
)

(define-private (is-valid-description (description (string-ascii 500)))
    (and
        (not (is-eq description ""))
        (<= (len description) u500)
    )
)

(define-private (is-valid-amount (amount uint))
    (and
        (> amount u0)
        (>= amount MIN_PROPOSAL_AMOUNT)
    )
)

(define-private (is-valid-recipient (recipient principal))
    (and
        (not (is-eq recipient tx-sender))
        (not (is-eq recipient (var-get dao-owner)))
    )
)

;; Private functions
(define-private (is-dao-member (member principal))
    (> (get-member-weight member) u0)
)

(define-private (check-proposal-active (proposal-id uint))
    (let (
        (proposal (unwrap! (get-proposal proposal-id) false))
        (current-block block-height)
    )
    (and
        (not (get executed proposal))
        (<= current-block (+ (get start-block proposal) VOTING_PERIOD))
    ))
)

;; Public functions with enhanced validation
(define-public (add-member (member principal) (weight uint))
    (begin
        (asserts! (is-eq tx-sender (var-get dao-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (is-valid-weight weight) ERR-INVALID-WEIGHT)
        (asserts! (not (is-dao-member member)) ERR-ALREADY-VOTED)
        
        ;; Update member count if this is a new member
        (if (is-eq (get-member-weight member) u0)
            (var-set total-members (+ (var-get total-members) u1))
            true
        )
        
        (ok (map-set member-weights member weight))
    )
)

(define-public (update-member-weight (member principal) (new-weight uint))
    (begin
        (asserts! (is-eq tx-sender (var-get dao-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (is-valid-weight new-weight) ERR-INVALID-WEIGHT)
        (asserts! (is-dao-member member) ERR-NOT-AUTHORIZED)
        
        (ok (map-set member-weights member new-weight))
    )
)

(define-public (create-proposal (title (string-ascii 50)) 
                              (description (string-ascii 500)) 
                              (amount uint)
                              (recipient principal))
    (let (
        (proposal-id (+ (var-get proposal-count) u1))
    )
        ;; Input validation
        (asserts! (is-dao-member tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (is-valid-title title) ERR-INVALID-TITLE)
        (asserts! (is-valid-description description) ERR-INVALID-DESCRIPTION)
        (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
        (asserts! (is-valid-recipient recipient) ERR-INVALID-RECIPIENT)
        
        ;; Check contract balance
        (asserts! (>= (stx-get-balance (as-contract tx-sender)) amount) ERR-INSUFFICIENT-FUNDS)
        
        (map-set proposals proposal-id {
            proposer: tx-sender,
            title: title,
            description: description,
            amount: amount,
            recipient: recipient,
            start-block: block-height,
            yes-votes: u0,
            no-votes: u0,
            executed: false
        })
        
        (var-set proposal-count proposal-id)
        (ok proposal-id)
    )
)
