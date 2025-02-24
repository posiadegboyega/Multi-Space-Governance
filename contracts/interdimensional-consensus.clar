;; Interdimensional Consensus Contract

(define-data-var next-proposal-id uint u0)

(define-map proposals
  { proposal-id: uint }
  {
    title: (string-ascii 64),
    description: (string-utf8 256),
    proposer: principal,
    votes-for: uint,
    votes-against: uint,
    status: (string-ascii 20)
  }
)

(define-public (create-proposal (title (string-ascii 64)) (description (string-utf8 256)))
  (let
    ((proposal-id (+ (var-get next-proposal-id) u1)))
    (var-set next-proposal-id proposal-id)
    (ok (map-set proposals
      { proposal-id: proposal-id }
      {
        title: title,
        description: description,
        proposer: tx-sender,
        votes-for: u0,
        votes-against: u0,
        status: "active"
      }
    ))
  )
)

(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let
    ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404))))
    (if vote
      (ok (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-for: (+ (get votes-for proposal) u1) })
      ))
      (ok (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-against: (+ (get votes-against proposal) u1) })
      ))
    )
  )
)

(define-public (finalize-proposal (proposal-id uint))
  (let
    ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404))))
    (ok (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal {
        status: (if (> (get votes-for proposal) (get votes-against proposal))
                  "passed"
                  "rejected")
      })
    ))
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

