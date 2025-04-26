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
