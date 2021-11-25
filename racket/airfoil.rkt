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
(define X-BASE
  (vector-map
    (lambda (x) (/ (- 1 (cos (/ (* pi x) M))) 2))
    (list->vector (inclusive-range 0 M))))

; Y without camber
(define Y-SIMETRIC
  (vector-map
    (lambda (x)
      (* 5 T (+ (* 0.2969 (sqrt x))
		(- (* 0.126 x))
		(- (* 0.3516 (expt x 2)))
		(* 0.2843 (expt x 3))
		(- (* 0.1036 (expt x 4))))))
    X-BASE))

; Camber
(define Y-CAMBER
  (vector-map
    (lambda (x)
      (if (<= x P)
	(* H (- (* 2 P x) (sqr x)) (/ 1 (sqr P)))
	(* H (/ 1 (sqr (- 1 P))) (+ 1 (- (* 2 P)) (* 2 P x) (- (sqr x))))))
    X-BASE))

(define THETA
  (vector-map
    (lambda (x)
      (atan (* 2 H (/ 1 (if (<= x P) (sqr P) (sqr (- 1 P)))) (- P x))))
    X-BASE))

(define X-UP (vector-map (lambda (x yt th) (- x (* yt (sin th))))
			 X-BASE Y-SIMETRIC THETA))
(define Y-UP (vector-map (lambda (yc yt th) (+ yc (* yt (cos th))))
			 Y-CAMBER Y-SIMETRIC THETA))
(define X-LO (vector-map (lambda (x yt th) (+ x (* yt (sin th))))
			 X-BASE Y-SIMETRIC THETA))
(define Y-LO (vector-map (lambda (yc yt th) (- yc (* yt (cos th))))
			 Y-CAMBER Y-SIMETRIC THETA))

(plot (list (lines (vector-map (lambda (x y) (vector x y)) X-UP Y-UP) #:color "red")
            (lines (vector-map (lambda (x y) (vector x y)) X-LO Y-LO) #:color "red")
            (lines (vector-map (lambda (x y) (vector x y)) X-BASE Y-CAMBER) #:color "blue"))
  #:x-min 0 #:x-max 1 #:y-min -0.3 #:y-max 0.3 #:aspect-ratio (/ 1 0.6))
