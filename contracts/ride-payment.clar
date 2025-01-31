;; Ride-sharing Payment Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-ride (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-ride-not-completed (err u103))
(define-constant err-already-paid (err u104))

;; Data variables
(define-map rides 
    { ride-id: uint }
    {
        driver: principal,
        passenger: principal,
        fare: uint,
        completed: bool,
        paid: bool
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
                paid: false
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
            paid: (get paid ride)
        })
    )
)
