#lang rackjure
;; run in project root where _reports is accessible

(require racket/hash
         json
         threading
         plot)

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

#;(~> (directory-list #:build? #t
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

(define lang-time-dict
  (~> (directory-list #:build? #t
                      (vector-ref (current-command-line-arguments) 0))
      (filter (λ (p) (path-has-extension? p ".json")) _)
      compute-lang-times-dict
      dict-average
      dict->list
      (sort _ < #:key cdr)
      (map (λ (x) (vector (car x) (cdr x))) _)))

(parameterize ([plot-font-size 14]
               [plot-title "Startup time for various languages"]
               [plot-x-label "Language"]
               [plot-y-label "Startup time (seconds)"]
               [plot-x-tick-label-anchor 'top-left]
               [plot-x-tick-label-angle -45]
               [plot-tick-size 0]
               [plot-width 800] [plot-height 500])
  (plot-file
   (discrete-histogram
    lang-time-dict
    #:x-min 0 #:x-max #f
    #:y-min 0 #:y-max 1)
   "histogram.png" 'png))
