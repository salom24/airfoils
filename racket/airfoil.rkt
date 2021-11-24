#lang racket

(require plot)
(plot-new-window? #t)

;; Variables
(define (get-NACA-input) (display "Choose a 4-digit NACA > ") (read-line))
;(writeln (get-NACA-input))

;(if (and (string? NACA) (= 4 (string-length NACA)) (andmap char-numeric? (string->list NACA))))

(define M 100)
(define H (/ 4 100))
(define P (/ 4 10))
(define T (/ 12 100))
(define U 10)
(define AOA (degrees->radians 0))

; X distribution
(define X-BASE (for/stream ([n (in-inclusive-range 0 M)])
            (/ (- 1 (cos (/ (* pi n) M))) 2)))

; Y without camber
(define Y-SIMETRIC (for/stream ([x X-BASE])
                     (* 5 T (+ (* 0.2969 (sqrt x))
                               (- (* 0.126 x))
                               (- (* 0.3516 (expt x 2)))
                               (* 0.2843 (expt x 3))
                               (- (* 0.1036 (expt x 4)))))))

; Camber
(define Y-CAMBER (for/stream ([x X-BASE])
                   (if (<= x P)
                       (* H (- (* 2 P x) (sqr x)) (/ 1 (sqr P)))
                       (* H (/ 1 (sqr (- 1 P))) (+ 1 (- (* 2 P)) (* 2 P x) (- (sqr x)))))))

(define THETA (for/stream ([x X-BASE])
                (atan (* 2 H (/ 1 (if (<= x P) (sqr P) (sqr (- 1 P)))) (- P x)))))

(define X-UP (for/stream ([x X-BASE] [yt Y-SIMETRIC] [th THETA])
               (- x (* yt (sin th)))))
(define Y-UP (for/stream ([yc Y-CAMBER] [yt Y-SIMETRIC] [th THETA])
               (+ yc (* yt (cos th)))))
(define X-LO (for/stream ([x X-BASE] [yt Y-SIMETRIC] [th THETA])
               (+ x (* yt (sin th)))))
(define Y-LO (for/stream ([yc Y-CAMBER] [yt Y-SIMETRIC] [th THETA])
               (- yc (* yt (cos th)))))

(plot (list (lines (for/stream ([x X-UP] [y Y-UP]) (vector x y)) #:color "red")
            (lines (for/stream ([x X-LO] [y Y-LO]) (vector x y)) #:color "red")
            (lines (for/stream ([x X-BASE] [y Y-CAMBER]) (vector x y)) #:color "blue"))
  #:x-min 0 #:x-max 1 #:y-min -0.3 #:y-max 0.3 #:aspect-ratio (/ 1 0.6))