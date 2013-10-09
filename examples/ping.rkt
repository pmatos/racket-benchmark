#lang racket

(require plot)
(require "../src/benchmark.rkt")

(define num-trials 5)

(define (ping count)
  (mk-shell-benchmark
   "ping"
   (format "ping -c ~a ccs.neu.edu" count)
   #:extract-result extract-time))

(define (extract-time str)
  (displayln str)
  (let* ([m (regexp-match
             #rx#"([a-z/]+) = ([0-9.]+)/([0-9.]+)/.*" str)])
    (if (not m)
        (error (format "Could not parse time output: ~a" str))
        (benchmark-trial-time 0 (bytes->number (cadddr m)) 0))))

(define (bytes->number b)
  (string->number (bytes->string/latin-1 b)))

(define benches
  (bgroup
   ""
   (map
    (lambda (n) (mk-bgroup (format "trial ~a" n) (list (ping 2))))
    (for/list ([i (in-range 0 num-trials)]) i))))

(define results
  (run-benchmarks
   benches
   #:benchmark-opts
   (bopts #:gc-between #f
          #:num-trials 30
          #:discard-first #f)))

(parameterize ([plot-x-ticks no-ticks])
  (plot-file
   (render-benchmark-alts
    (map (lambda (n) (format "trial ~a" n))
         (for/list ([i (in-range 0 num-trials)]) i))
    results "trial 0")
   "ping.pdf"))