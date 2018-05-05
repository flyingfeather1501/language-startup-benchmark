#lang rackjure
;; run in project root where _reports is accessible
(require racket/hash
         json
         threading)

(define (average/list vals)
  (/ (apply + vals) (length vals)))

(current-directory "_reports")
(define files (directory-list))

(define (file->lang-time-dict f)
  (~> (file->string f)
      string->jsexpr ; now a list of hashes
      (map (λ (h)
              (cons
                (~> h 'report 'title)
                (~> h 'report 'time)))
           _)
      make-immutable-hash)) ; ((title . time) (title . time) ...)

(define (compute-lang-times-dict files)
  ;; Computes a dictionary with languages as keys and all the times as values
  (apply hash-union #:combine/key (lambda (k . vs) (flatten vs))
         (map file->lang-time-dict files)))

(define (dict-average d)
  ;; dict (any . (listof number)) -> dict (any . number)
  ;; take the average of the old value and use that as the new value
  (define (avg-iter d keys)
    (cond [(empty? keys) d]
          [else (avg-iter
                  (dict-update d (first keys) average/list)
                  (rest keys))]))
  (avg-iter d (dict-keys d)))

;; (average-value (compute-lang-times-dict (directory-list)))
