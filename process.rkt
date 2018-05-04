#lang rackjure
;; run in project root where _reports is accessible
(require json)

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
           _))) ; ((title . time) (title . time) ...)

(define lang-times-dict
  ;; A dictionary with languages as keys and all the times as values
  (map (λ (l)
          "Grab the times of this language from each dict"
          (~> (map (λ (d)
                      (dict-ref d l))
                   (map file->lang-time-dict (directory-list)))
              (cons l _))) ; attach the language key
       ;; the languages
       (dict-keys (file->lang-time-dict (first (directory-list))))))

(define (average-value d)
  ;; dict (string . (listof number)) -> dict (string . number)
  ;; take the average of the old value and use that as the new value
  (map (λ (k)
          (cons k
                (apply average (dict-ref d k))))
       (dict-keys d)))

(average-value lang-times-dict)
