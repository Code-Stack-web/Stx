;; smart-project-solver.clar
;; New Clarity project contract for Google Clarity Web3

(define-data-var project-index uint u0)

(define-map projects ((id uint))
  ((owner principal)
   (task (string-ascii 70))
   (result (string-ascii 70))
   (status (string-ascii 12))))

;; Step 1: Register a project with a task
(define-public (register-project (task (string-ascii 70)))
  (let ((id (var-get project-index)))
    (begin
      (map-set projects id
        ((owner tx-sender)
         (task task)
         (result "")
         (status "new")))
      (var-set project-index (+ id u1))
      (ok id)
    )
  )
)

;; Step 2: Submit a result to solve the task
(define-public (submit-result (id uint) (result (string-ascii 70)))
  (match (map-get? projects id)
    project
      (if (is-eq (get status project) "new")
          (begin
            (map-set projects id
              ((owner (get owner project))
               (task (get task project))
               (result result)
               (status "solved")))
            (ok "Result submitted"))
          (err u1)) ;; wrong status
    (err u2) ;; project not found
  )
)

;; Step 3: Approve the project and grant a contract
(define-public (grant-contract (id uint))
  (match (map-get? projects id)
    project
      (if (is-eq (get status project) "solved")
          (begin
            (map-set projects id
              ((owner (get owner project))
               (task (get task project))
               (result (get result project))
               (status "contracted")))
            (ok "Contract granted"))
          (err u3)) ;; must be solved
    (err u4) ;; project not found
  )
)
