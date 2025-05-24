;; Certification Contract
;; Issues and manages sustainable material certifications

(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u401))
(define-constant err-not-found (err u402))
(define-constant err-already-certified (err u403))

;; Certification data
(define-map certifications
  { cert-id: uint }
  {
    material-id: uint,
    cert-type: (string-ascii 30),
    issuer: principal,
    issue-date: uint,
    expiry-date: uint,
    valid: bool
  }
)

(define-data-var next-cert-id uint u1)

;; Authorized certifiers
(define-map authorized-certifiers principal bool)

;; Initialize contract owner as authorized certifier
(map-set authorized-certifiers contract-owner true)

;; Add authorized certifier
(define-public (add-certifier (certifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (map-set authorized-certifiers certifier true)
    (ok true)
  )
)

;; Issue certification
(define-public (issue-certification
  (material-id uint)
  (cert-type (string-ascii 30))
  (validity-period uint)
)
  (let ((cert-id (var-get next-cert-id)))
    (asserts! (default-to false (map-get? authorized-certifiers tx-sender)) err-not-authorized)
    (map-set certifications
      { cert-id: cert-id }
      {
        material-id: material-id,
        cert-type: cert-type,
        issuer: tx-sender,
        issue-date: block-height,
        expiry-date: (+ block-height validity-period),
        valid: true
      }
    )
    (var-set next-cert-id (+ cert-id u1))
    (ok cert-id)
  )
)

;; Revoke certification
(define-public (revoke-certification (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert-data
    (begin
      (asserts! (is-eq tx-sender (get issuer cert-data)) err-not-authorized)
      (map-set certifications
        { cert-id: cert-id }
        (merge cert-data { valid: false })
      )
      (ok true)
    )
    err-not-found
  )
)

;; Get certification
(define-read-only (get-certification (cert-id uint))
  (map-get? certifications { cert-id: cert-id })
)

;; Check if certification is valid
(define-read-only (is-certification-valid (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert-data
    (and
      (get valid cert-data)
      (< block-height (get expiry-date cert-data))
    )
    false
  )
)
