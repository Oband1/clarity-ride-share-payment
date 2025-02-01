;; Ride-sharing Payment Contract with Rating & Dispute System

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-ride (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-ride-not-completed (err u103))
(define-constant err-already-paid (err u104))
(define-constant err-invalid-rating (err u105))
(define-constant err-already-rated (err u106))
(define-constant err-dispute-exists (err u107))
(define-constant err-no-dispute (err u108))
(define-constant min-rating u1)
(define-constant max-rating u5)

;; Data variables
(define-map rides 
    { ride-id: uint }
    {
        driver: principal,
        passenger: principal,
        fare: uint,
        completed: bool,
        paid: bool,
        passenger-rating: (optional uint),
        driver-rating: (optional uint),
        disputed: bool,
        dispute-resolved: bool
    }
)

(define-map disputes
    { ride-id: uint }
    {
        reason: (string-ascii 256),
        refund-requested: uint,
        resolved: bool,
        resolution: (optional (string-ascii 256))
    }
)

;; Public functions
(define-public (create-ride (ride-id uint) (driver principal) (passenger principal) (fare uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set rides 
            { ride-id: ride-id }
            {
                driver: driver,
                passenger: passenger,
                fare: fare,
                completed: false,
                paid: false,
                passenger-rating: none,
                driver-rating: none,
                disputed: false,
                dispute-resolved: false
            }
        )
        (ok true)
    )
)

(define-public (complete-ride (ride-id uint))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
    )
        (asserts! (is-eq tx-sender (get driver ride)) err-owner-only)
        (map-set rides
            { ride-id: ride-id }
            (merge ride { completed: true })
        )
        (ok true)
    )
)

(define-public (pay-ride (ride-id uint))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
    )
        (asserts! (is-eq tx-sender (get passenger ride)) err-owner-only)
        (asserts! (get completed ride) err-ride-not-completed)
        (asserts! (not (get paid ride)) err-already-paid)
        
        (try! (stx-transfer? (get fare ride) tx-sender (get driver ride)))
        
        (map-set rides
            { ride-id: ride-id }
            (merge ride { paid: true })
        )
        (ok true)
    )
)

(define-public (rate-ride (ride-id uint) (rating uint) (is-driver bool))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
    )
        (asserts! (and (>= rating min-rating) (<= rating max-rating)) err-invalid-rating)
        (asserts! (get completed ride) err-ride-not-completed)
        
        (if is-driver
            (begin
                (asserts! (is-eq tx-sender (get driver ride)) err-owner-only)
                (asserts! (is-none (get passenger-rating ride)) err-already-rated)
                (map-set rides
                    { ride-id: ride-id }
                    (merge ride { passenger-rating: (some rating) })
                )
            )
            (begin
                (asserts! (is-eq tx-sender (get passenger ride)) err-owner-only)
                (asserts! (is-none (get driver-rating ride)) err-already-rated)
                (map-set rides
                    { ride-id: ride-id }
                    (merge ride { driver-rating: (some rating) })
                )
            )
        )
        (ok true)
    )
)

(define-public (file-dispute (ride-id uint) (reason (string-ascii 256)) (refund-amount uint))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
    )
        (asserts! (is-eq tx-sender (get passenger ride)) err-owner-only)
        (asserts! (get completed ride) err-ride-not-completed)
        (asserts! (get paid ride) err-insufficient-balance)
        (asserts! (not (get disputed ride)) err-dispute-exists)
        
        (map-set disputes
            { ride-id: ride-id }
            {
                reason: reason,
                refund-requested: refund-amount,
                resolved: false,
                resolution: none
            }
        )
        
        (map-set rides
            { ride-id: ride-id }
            (merge ride { disputed: true })
        )
        (ok true)
    )
)

(define-public (resolve-dispute (ride-id uint) (resolution (string-ascii 256)) (refund-amount uint))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
        (dispute (unwrap! (map-get? disputes { ride-id: ride-id }) err-no-dispute))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (get disputed ride) err-no-dispute)
        (asserts! (not (get dispute-resolved ride)) err-dispute-exists)
        
        (if (> refund-amount u0)
            (try! (stx-transfer? refund-amount (get driver ride) (get passenger ride)))
            true
        )
        
        (map-set disputes
            { ride-id: ride-id }
            (merge dispute {
                resolved: true,
                resolution: (some resolution)
            })
        )
        
        (map-set rides
            { ride-id: ride-id }
            (merge ride { dispute-resolved: true })
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-ride-details (ride-id uint))
    (ok (map-get? rides { ride-id: ride-id }))
)

(define-read-only (get-ride-status (ride-id uint))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
    )
        (ok {
            completed: (get completed ride),
            paid: (get paid ride),
            disputed: (get disputed ride),
            dispute-resolved: (get dispute-resolved ride)
        })
    )
)

(define-read-only (get-dispute-details (ride-id uint))
    (ok (map-get? disputes { ride-id: ride-id }))
)
