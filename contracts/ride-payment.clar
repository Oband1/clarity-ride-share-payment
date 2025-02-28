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
(define-constant err-ride-exists (err u109))
(define-constant err-invalid-fare (err u110))
(define-constant min-rating u1)
(define-constant max-rating u5)

;; [Previous map definitions remain unchanged]

(define-public (create-ride (ride-id uint) (driver principal) (passenger principal) (fare uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (map-get? rides { ride-id: ride-id })) err-ride-exists)
        (asserts! (> fare u0) err-invalid-fare)
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

;; [Other functions remain unchanged until resolve-dispute]

(define-public (resolve-dispute (ride-id uint) (resolution (string-ascii 256)) (refund-amount uint))
    (let (
        (ride (unwrap! (map-get? rides { ride-id: ride-id }) err-invalid-ride))
        (dispute (unwrap! (map-get? disputes { ride-id: ride-id }) err-no-dispute))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (get disputed ride) err-no-dispute)
        (asserts! (not (get dispute-resolved ride)) err-dispute-exists)
        
        ;; Update state before transfer
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
        
        ;; Perform transfer last
        (if (> refund-amount u0)
            (try! (stx-transfer? refund-amount (get driver ride) (get passenger ride)))
            (ok true)
        )
    )
)

;; [Read-only functions remain unchanged]
