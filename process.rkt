#lang rackjure
;; run in project root where _reports is accessible

(require racket/hash
         json
         threading)

(define (average/list vals)
  (/ (apply + vals) (length vals)))

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

;; (current-directory "_reports")

(define (lang-time-dict->string d)
  (~> (dict->list d)
      (sort _ < #:key cdr)
      (map (λ (x) (string-append (~a (cdr x)) " "
                                 "\"" (car x) "\""))
           _)
      ;; add 0, 1, 2... in front
      (map (λ (s i) (string-append s i))
           _
           (stream->list (in-range (length d))))))

(~> (directory-list #:build? #t
                    (vector-ref (current-command-line-arguments) 0))
    (filter (λ (p) (path-has-extension? p ".json")) _)
    compute-lang-times-dict
    dict-average
    dict->list
    (sort _ < #:key cdr) ; sort by second element (time)
    (map (λ (i) (string-append (~a (cdr i)) " "
                               "\"" (car i) "\"")) _)
    (string-join _ "\n")
    displayln)

;; (average-value (compute-lang-times-dict (directory-list)))
