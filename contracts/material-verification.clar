;; Material Verification Contract
;; Validates sustainable inputs and manages material registry

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Material data structure
(define-map materials
  { material-id: uint }
  {
    name: (string-ascii 50),
    type: (string-ascii 30),
    verified: bool,
    verifier: principal,
    timestamp: uint
  }
)

(define-data-var next-material-id uint u1)

;; Register a new material
(define-public (register-material (name (string-ascii 50)) (material-type (string-ascii 30)))
  (let ((material-id (var-get next-material-id)))
    (asserts! (is-none (map-get? materials { material-id: material-id })) err-already-exists)
    (map-set materials
      { material-id: material-id }
      {
        name: name,
        type: material-type,
        verified: false,
        verifier: tx-sender,
        timestamp: block-height
      }
    )
    (var-set next-material-id (+ material-id u1))
    (ok material-id)
  )
)

;; Verify a material
(define-public (verify-material (material-id uint))
  (match (map-get? materials { material-id: material-id })
    material-data
    (begin
      (map-set materials
        { material-id: material-id }
        (merge material-data { verified: true, verifier: tx-sender })
      )
      (ok true)
    )
    err-not-found
  )
)

;; Get material info
(define-read-only (get-material (material-id uint))
  (map-get? materials { material-id: material-id })
)

;; Check if material is verified
(define-read-only (is-verified (material-id uint))
  (match (map-get? materials { material-id: material-id })
    material-data (get verified material-data)
    false
  )
)
