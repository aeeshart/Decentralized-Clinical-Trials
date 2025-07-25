;; Decentralized Clinical Trials Smart Contract
;; Patient-owned trial participation with transparent results

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-phase (err u103))
(define-constant err-trial-closed (err u104))
(define-constant err-already-enrolled (err u105))
(define-constant err-insufficient-funds (err u106))
(define-constant err-invalid-status (err u107))

;; Data Variables
(define-data-var next-trial-id uint u1)
(define-data-var next-patient-id uint u1)

;; Trial Status Types
(define-constant status-planning u0)
(define-constant status-recruiting u1)
(define-constant status-active u2)
(define-constant status-completed u3)
(define-constant status-terminated u4)

;; Trial Phases
(define-constant phase-i u1)
(define-constant phase-ii u2)
(define-constant phase-iii u3)
(define-constant phase-iv u4)

;; Data Maps
(define-map trials
  uint
  {
    sponsor: principal,
    title: (string-ascii 200),
    description: (string-utf8 500),
    phase: uint,
    status: uint,
    max-participants: uint,
    current-participants: uint,
    start-date: uint,
    end-date: uint,
    compensation: uint,
    inclusion-criteria: (string-utf8 300),
    exclusion-criteria: (string-utf8 300),
    primary-endpoint: (string-utf8 200),
    secondary-endpoints: (string-utf8 300),
    results-hash: (optional (buff 32)),
    created-at: uint
  }
)

(define-map patients
  uint
  {
    wallet: principal,
    age: uint,
    gender: (string-ascii 10),
    medical-history-hash: (buff 32),
    consent-hash: (buff 32),
    enrolled-trials: (list 10 uint),
    total-compensation: uint,
    created-at: uint
  }
)

(define-map trial-enrollments
  {trial-id: uint, patient-id: uint}
  {
    enrollment-date: uint,
    status: (string-ascii 20),
    compensation-paid: uint,
    data-submissions: uint,
    completion-date: (optional uint),
    withdrawal-reason: (optional (string-utf8 200))
  }
)

(define-map patient-data
  {trial-id: uint, patient-id: uint, submission-id: uint}
  {
    data-hash: (buff 32),
    timestamp: uint,
    verified: bool,
    compensation: uint
  }
)

(define-map trial-results
  uint
  {
    primary-outcome: (string-utf8 500),
    secondary-outcomes: (string-utf8 500),
    adverse-events: (string-utf8 500),
    statistical-analysis: (string-utf8 500),
    publication-hash: (optional (buff 32)),
    peer-reviewed: bool,
    published-at: uint
  }
)

;; Authorization Maps
(define-map authorized-researchers principal bool)
(define-map trial-investigators {trial-id: uint} (list 5 principal))

;; Read-only functions
(define-read-only (get-trial (trial-id uint))
  (map-get? trials trial-id)
)

(define-read-only (get-patient (patient-id uint))
  (map-get? patients patient-id)
)

(define-read-only (get-enrollment (trial-id uint) (patient-id uint))
  (map-get? trial-enrollments {trial-id: trial-id, patient-id: patient-id})
)

(define-read-only (get-trial-results (trial-id uint))
  (map-get? trial-results trial-id)
)

(define-read-only (get-patient-data (trial-id uint) (patient-id uint) (submission-id uint))
  (map-get? patient-data {trial-id: trial-id, patient-id: patient-id, submission-id: submission-id})
)

(define-read-only (is-authorized-researcher (researcher principal))
  (default-to false (map-get? authorized-researchers researcher))
)

(define-read-only (get-next-trial-id)
  (var-get next-trial-id)
)

(define-read-only (get-next-patient-id)
  (var-get next-patient-id)
)

;; Private functions
(define-private (is-trial-sponsor (trial-id uint) (user principal))
  (match (map-get? trials trial-id)
    trial (is-eq (get sponsor trial) user)
    false
  )
)

;; Public functions

;; Authorize researcher
(define-public (authorize-researcher (researcher principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-researchers researcher true))
  )
)

;; Create new clinical trial
(define-public (create-trial 
    (title (string-ascii 200))
    (description (string-utf8 500))
    (phase uint)
    (max-participants uint)
    (start-date uint)
    (end-date uint)
    (compensation uint)
    (inclusion-criteria (string-utf8 300))
    (exclusion-criteria (string-utf8 300))
    (primary-endpoint (string-utf8 200))
    (secondary-endpoints (string-utf8 300))
  )
  (let
    (
      (trial-id (var-get next-trial-id))
    )
    (asserts! (is-authorized-researcher tx-sender) err-unauthorized)
    (asserts! (and (>= phase phase-i) (<= phase phase-iv)) err-invalid-phase)
    
    (map-set trials trial-id
      {
        sponsor: tx-sender,
        title: title,
        description: description,
        phase: phase,
        status: status-planning,
        max-participants: max-participants,
        current-participants: u0,
        start-date: start-date,
        end-date: end-date,
        compensation: compensation,
        inclusion-criteria: inclusion-criteria,
        exclusion-criteria: exclusion-criteria,
        primary-endpoint: primary-endpoint,
        secondary-endpoints: secondary-endpoints,
        results-hash: none,
        created-at: block-height
      }
    )
    
    (var-set next-trial-id (+ trial-id u1))
    (ok trial-id)
  )
)

;; Register patient
(define-public (register-patient
    (age uint)
    (gender (string-ascii 10))
    (medical-history-hash (buff 32))
    (consent-hash (buff 32))
  )
  (let
    (
      (patient-id (var-get next-patient-id))
    )
    (map-set patients patient-id
      {
        wallet: tx-sender,
        age: age,
        gender: gender,
        medical-history-hash: medical-history-hash,
        consent-hash: consent-hash,
        enrolled-trials: (list),
        total-compensation: u0,
        created-at: block-height
      }
    )
    
    (var-set next-patient-id (+ patient-id u1))
    (ok patient-id)
  )
)

;; Update trial status
(define-public (update-trial-status (trial-id uint) (new-status uint))
  (let
    (
      (trial (unwrap! (map-get? trials trial-id) err-not-found))
    )
    (asserts! (is-trial-sponsor trial-id tx-sender) err-unauthorized)
    (asserts! (<= new-status status-terminated) err-invalid-status)
    
    (map-set trials trial-id (merge trial {status: new-status}))
    (ok true)
  )
)

;; Enroll patient in trial
(define-public (enroll-patient (trial-id uint) (patient-id uint))
  (let
    (
      (trial (unwrap! (map-get? trials trial-id) err-not-found))
      (patient (unwrap! (map-get? patients patient-id) err-not-found))
    )
    (asserts! (is-eq (get wallet patient) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status trial) status-recruiting) err-trial-closed)
    (asserts! (< (get current-participants trial) (get max-participants trial)) err-trial-closed)
    (asserts! (is-none (map-get? trial-enrollments {trial-id: trial-id, patient-id: patient-id})) err-already-enrolled)
    
    ;; Create enrollment record
    (map-set trial-enrollments {trial-id: trial-id, patient-id: patient-id}
      {
        enrollment-date: block-height,
        status: "enrolled",
        compensation-paid: u0,
        data-submissions: u0,
        completion-date: none,
        withdrawal-reason: none
      }
    )
    
    ;; Update trial participant count
    (map-set trials trial-id 
      (merge trial {current-participants: (+ (get current-participants trial) u1)})
    )
    
    ;; Update patient enrolled trials
    (let
      (
        (updated-trials (unwrap! (as-max-len? (append (get enrolled-trials patient) trial-id) u10) err-not-found))
      )
      (map-set patients patient-id (merge patient {enrolled-trials: updated-trials}))
    )
    
    (ok true)
  )
)

;; Submit patient data
(define-public (submit-patient-data 
    (trial-id uint) 
    (patient-id uint) 
    (submission-id uint)
    (data-hash (buff 32))
  )
  (let
    (
      (enrollment (unwrap! (map-get? trial-enrollments {trial-id: trial-id, patient-id: patient-id}) err-not-found))
      (patient (unwrap! (map-get? patients patient-id) err-not-found))
      (trial (unwrap! (map-get? trials trial-id) err-not-found))
    )
    (asserts! (is-eq (get wallet patient) tx-sender) err-unauthorized)
    
    (map-set patient-data {trial-id: trial-id, patient-id: patient-id, submission-id: submission-id}
      {
        data-hash: data-hash,
        timestamp: block-height,
        verified: false,
        compensation: (get compensation trial)
      }
    )
    
    ;; Update enrollment data submissions count
    (map-set trial-enrollments {trial-id: trial-id, patient-id: patient-id}
      (merge enrollment {data-submissions: (+ (get data-submissions enrollment) u1)})
    )
    
    (ok true)
  )
)

;; Publish trial results
(define-public (publish-results
    (trial-id uint)
    (primary-outcome (string-utf8 500))
    (secondary-outcomes (string-utf8 500))
    (adverse-events (string-utf8 500))
    (statistical-analysis (string-utf8 500))
    (publication-hash (optional (buff 32)))
  )
  (let
    (
      (trial (unwrap! (map-get? trials trial-id) err-not-found))
    )
    (asserts! (is-trial-sponsor trial-id tx-sender) err-unauthorized)
    (asserts! (is-eq (get status trial) status-completed) err-invalid-status)
    
    (map-set trial-results trial-id
      {
        primary-outcome: primary-outcome,
        secondary-outcomes: secondary-outcomes,
        adverse-events: adverse-events,
        statistical-analysis: statistical-analysis,
        publication-hash: publication-hash,
        peer-reviewed: false,
        published-at: block-height
      }
    )
    
    (ok true)
  )
)

;; Pay patient compensation
(define-public (pay-compensation (trial-id uint) (patient-id uint) (amount uint))
  (let
    (
      (trial (unwrap! (map-get? trials trial-id) err-not-found))
      (patient (unwrap! (map-get? patients patient-id) err-not-found))
      (enrollment (unwrap! (map-get? trial-enrollments {trial-id: trial-id, patient-id: patient-id}) err-not-found))
    )
    (asserts! (is-trial-sponsor trial-id tx-sender) err-unauthorized)
    
    ;; Transfer STX to patient
    (try! (stx-transfer? amount tx-sender (get wallet patient)))
    
    ;; Update enrollment compensation
    (map-set trial-enrollments {trial-id: trial-id, patient-id: patient-id}
      (merge enrollment {compensation-paid: (+ (get compensation-paid enrollment) amount)})
    )
    
    ;; Update patient total compensation
    (map-set patients patient-id 
      (merge patient {total-compensation: (+ (get total-compensation patient) amount)})
    )
    
    (ok true)
  )
)