;; LifeQuest Objectives
;; The system preserves participant confidentiality through identity-based record association.


;; Primary repository for participant objectives
;; Associates participant identities with their objective data
(define-map participant-objectives
    principal
    {
        context: (string-ascii 100),
        completed: bool
    }
)

;; Response codes for operational feedback
(define-constant OBJECTIVE-ALREADY-EXISTS (err u409))
(define-constant OBJECTIVE-MALFORMED-INPUT (err u400))
(define-constant OBJECTIVE-NONEXISTENT (err u404))

;; Repository for objective completion timeframes
;; Tracks target completion blocks and notification status
(define-map objective-timeframes
    principal
    {
        target-block: uint,
        alert-delivered: bool
    }
)

;; Repository for objective importance classification
;; Enables tiered importance classification system
(define-map objective-importance
    principal
    {
        importance-tier: uint
    }
)

;; Public function to establish a new objective
(define-public (establish-objective 
    (context (string-ascii 100)))
    (let
        (
            (entity tx-sender)
            (existing-entry (map-get? participant-objectives entity))
        )
        (if (is-none existing-entry)
            (begin
                (if (is-eq context "")
                    (err OBJECTIVE-MALFORMED-INPUT)
                    (begin
                        (map-set participant-objectives entity
                            {
                                context: context,
                                completed: false
                            }
                        )
                        (ok "Objective successfully established.")
                    )
                )
            )
            (err OBJECTIVE-ALREADY-EXISTS)
        )
    )
)

;; Public function to update an existing objective's details
(define-public (update-objective
    (context (string-ascii 100))
    (completed bool))
    (let
        (
            (entity tx-sender)
            (existing-entry (map-get? participant-objectives entity))
        )
        (if (is-some existing-entry)
            (begin
                (if (is-eq context "")
                    (err OBJECTIVE-MALFORMED-INPUT)
                    (begin
                        (if (or (is-eq completed true) (is-eq completed false))
                            (begin
                                (map-set participant-objectives entity
                                    {
                                        context: context,
                                        completed: completed
                                    }
                                )
                                (ok "Objective successfully updated.")
                            )
                            (err OBJECTIVE-MALFORMED-INPUT)
                        )
                    )
                )
            )
            (err OBJECTIVE-NONEXISTENT)
        )
    )
)

;; Public function to eliminate an objective
(define-public (eliminate-objective)
    (let
        (
            (entity tx-sender)
            (existing-entry (map-get? participant-objectives entity))
        )
        (if (is-some existing-entry)
            (begin
                (map-delete participant-objectives entity)
                (ok "Objective successfully eliminated.")
            )
            (err OBJECTIVE-NONEXISTENT)
        )
    )
)

;; Public function to specify objective timeframe
(define-public (specify-objective-timeframe (blocks-ahead uint))
    (let
        (
            (entity tx-sender)
            (existing-entry (map-get? participant-objectives entity))
            (completion-block (+ block-height blocks-ahead))
        )
        (if (is-some existing-entry)
            (if (> blocks-ahead u0)
                (begin
                    (map-set objective-timeframes entity
                        {
                            target-block: completion-block,
                            alert-delivered: false
                        }
                    )
                    (ok "Objective timeframe successfully specified.")
                )
                (err OBJECTIVE-MALFORMED-INPUT)
            )
            (err OBJECTIVE-NONEXISTENT)
        )
    )
)

;; Public function to assign importance tier to objectives
(define-public (assign-importance-tier (importance-tier uint))
    (let
        (
            (entity tx-sender)
            (existing-entry (map-get? participant-objectives entity))
        )
        (if (is-some existing-entry)
            (if (and (>= importance-tier u1) (<= importance-tier u3))
                (begin
                    (map-set objective-importance entity
                        {
                            importance-tier: importance-tier
                        }
                    )
                    (ok "Objective importance successfully assigned.")
                )
                (err OBJECTIVE-MALFORMED-INPUT)
            )
            (err OBJECTIVE-NONEXISTENT)
        )
    )
)

;; Public function to validate objective existence and retrieve metadata
(define-public (verify-objective-validity)
    (let
        (
            (entity tx-sender)
            (existing-entry (map-get? participant-objectives entity))
        )
        (if (is-some existing-entry)
            (let
                (
                    (current-entry (unwrap! existing-entry OBJECTIVE-NONEXISTENT))
                    (objective-context (get context current-entry))
                    (objective-completion (get completed current-entry))
                )
                (ok {
                    exists: true,
                    context-size: (len objective-context),
                    is-fulfilled: objective-completion
                })
            )
            (ok {
                exists: false,
                context-size: u0,
                is-fulfilled: false
            })
        )
    )
)

;; Public function allowing delegation of objectives to other participants
(define-public (delegate-objective
    (target-entity principal)
    (context (string-ascii 100)))
    (let
        (
            (existing-entry (map-get? participant-objectives target-entity))
        )
        (if (is-none existing-entry)
            (begin
                (if (is-eq context "")
                    (err OBJECTIVE-MALFORMED-INPUT)
                    (begin
                        (map-set participant-objectives target-entity
                            {
                                context: context,
                                completed: false
                            }
                        )
                        (ok "Objective successfully delegated.")
                    )
                )
            )
            (err OBJECTIVE-ALREADY-EXISTS)
        )
    )
)

