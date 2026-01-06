(define-map switch 
  principal 
  { beneficiary: principal, last-heartbeat: uint, interval: uint, amount: uint }
)

(define-constant ERR_INVALID_PARAMS (err u400))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_NOT_ELIGIBLE (err u403))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-public (register (beneficiary principal) (interval uint) (amount uint))
  (begin
    (asserts! (is-none (map-get? switch tx-sender)) ERR_ALREADY_EXISTS)
    (asserts! (> interval u0) ERR_INVALID_PARAMS)
    (asserts! (> amount u0) ERR_INVALID_PARAMS)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok (map-set switch tx-sender { beneficiary: beneficiary, last-heartbeat: burn-block-height, interval: interval, amount: amount }))
  )
)

(define-public (heartbeat)
  (let ((entry (unwrap! (map-get? switch tx-sender) ERR_NOT_FOUND)))
    (ok (map-set switch tx-sender (merge entry { last-heartbeat: burn-block-height })))
  )
)

(define-public (claim (target principal))
  (let ((entry (unwrap! (map-get? switch target) ERR_NOT_FOUND)))
    (asserts! (>= burn-block-height (+ (get last-heartbeat entry) (get interval entry))) ERR_NOT_ELIGIBLE)
    (try! (as-contract (stx-transfer? (get amount entry) tx-sender (get beneficiary entry))))
    (map-delete switch target)
    (ok true)
  )
)

(define-public (cancel)
  (let ((caller tx-sender))
    (let ((entry (unwrap! (map-get? switch caller) ERR_NOT_FOUND)))
      (try! (as-contract (stx-transfer? (get amount entry) tx-sender caller)))
      (map-delete switch caller)
      (ok true)
    )
  )
)
