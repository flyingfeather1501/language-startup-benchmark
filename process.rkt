#lang rackjure
;; run in project root where _reports is accessible
(require racket/hash
         json
         threading)

(define (average . vals)
  (/ (apply + vals) (length vals)))

(current-directory "_reports")

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
  ;; files: listof path?
  ;; A dictionary with languages as keys and all the times as values
  (map (λ (l)
          "Grab the times of this language from each dict"
          (~> (map file->lang-time-dict files)
              (map (λ (d) (dict-ref d l)) _)
              (cons l _))) ; attach the language key
       ;; the languages
       (dict-keys (file->lang-time-dict (first files)))))

(define (average-value d)
  ;; dict (string . (listof number)) -> dict (string . number)
  ;; take the average of the old value and use that as the new value
  (map (λ (k)
          (cons k
                (apply average (dict-ref d k))))
       (dict-keys d)))

;; (average-value (compute-lang-times-dict (directory-list)))
