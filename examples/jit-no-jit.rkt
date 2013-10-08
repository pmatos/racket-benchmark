#lang racket

(require "../src/benchmark.rkt")

(require plot)

(define files (list
               "external/fib5.rkt"
               "external/fib30.rkt"
               "external/collatz1000.rkt"
               ))

(define (jit-no-jit jit)
  (mk-benchmark-group
   (if jit "jit" "no jit")
   (map (lambda (f)
          (mk-shell-benchmark
           f
           (format (if jit "racket ~a" "racket -j ~a") f)))
    files)))

(define results
  (run-benchmarks
   (mk-benchmark-group "" (list (jit-no-jit #t) (jit-no-jit #f)))
   #:benchmark-opts (mk-benchmark-opts #:num-trials 31)))

(parameterize ([plot-x-ticks no-ticks])
  (plot-file
   (render-benchmark-alts (list "jit" "no jit") results "jit")
   "jit-no-jit.pdf"))


