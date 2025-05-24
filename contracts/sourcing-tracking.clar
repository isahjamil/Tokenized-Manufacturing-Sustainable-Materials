;; Sourcing Tracking Contract
;; Records material origins and supply chain data

(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u201))
(define-constant err-unauthorized (err u202))

;; Source tracking data
(define-map source-records
  { tracking-id: uint }
  {
    material-id: uint,
    origin: (string-ascii 100),
    supplier: principal,
    coordinates: (string-ascii 50),
    harvest-date: uint,
    transport-method: (string-ascii 30)
  }
)

(define-data-var next-tracking-id uint u1)

;; Record material source
(define-public (record-source
  (material-id uint)
  (origin (string-ascii 100))
  (coordinates (string-ascii 50))
  (harvest-date uint)
  (transport-method (string-ascii 30))
)
  (let ((tracking-id (var-get next-tracking-id)))
    (map-set source-records
      { tracking-id: tracking-id }
      {
        material-id: material-id,
        origin: origin,
        supplier: tx-sender,
        coordinates: coordinates,
        harvest-date: harvest-date,
        transport-method: transport-method
      }
    )
    (var-set next-tracking-id (+ tracking-id u1))
    (ok tracking-id)
  )
)

;; Get source record
(define-read-only (get-source-record (tracking-id uint))
  (map-get? source-records { tracking-id: tracking-id })
)

;; Get records by material
(define-read-only (get-material-sources (material-id uint))
  ;; In a real implementation, this would iterate through records
  ;; For simplicity, returning a placeholder
  (some { material-id: material-id, count: u1 })
)
