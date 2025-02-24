;; Dimension Mapping Contract

(define-data-var next-dimension-id uint u0)

(define-map dimensions
  { dimension-id: uint }
  {
    name: (string-ascii 64),
    description: (string-utf8 256),
    stability: uint,
    last-interaction: uint
  }
)

(define-public (register-dimension (name (string-ascii 64)) (description (string-utf8 256)))
  (let
    ((dimension-id (+ (var-get next-dimension-id) u1)))
    (var-set next-dimension-id dimension-id)
    (ok (map-set dimensions
      { dimension-id: dimension-id }
      {
        name: name,
        description: description,
        stability: u100,
        last-interaction: block-height
      }
    ))
  )
)

(define-public (update-dimension-stability (dimension-id uint) (new-stability uint))
  (let
    ((dimension (unwrap! (map-get? dimensions { dimension-id: dimension-id }) (err u404))))
    (ok (map-set dimensions
      { dimension-id: dimension-id }
      (merge dimension {
        stability: new-stability,
        last-interaction: block-height
      })
    ))
  )
)

(define-read-only (get-dimension (dimension-id uint))
  (map-get? dimensions { dimension-id: dimension-id })
)

