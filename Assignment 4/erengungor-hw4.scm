(define check-triple?
    (lambda (tripleList)
        (letrec ((isTripleValid
            (lambda (triple)
                (and 
                    (list? triple)
                    (= (length triple) 3)
                    (number? (car triple))
                    (number? (cadr triple))
                    (number? (caddr triple))
                )
            )   ))
        (let loop ((lst tripleList)) 
            (cond 
                ((null? lst) #t) ; All clear
                ((not (isTripleValid (car lst))) #f) ; Invalid triple
                (else (loop (cdr lst)))
            )
        ))
    )
)
;---------------------------------------------------------------------------
(define check-length?
    (lambda (inTriple count)
        (letrec ((checkLength
            (lambda (lst count)
                (cond 
                    ((null? lst) (= count 0))
                    ((= count 0) #f)
                    (else (checkLength (cdr lst) (- count 1)))
                )
            )   ))
            (checkLength inTriple count)
        )
    )
)
;---------------------------------------------------------------------------
(define check-sides?
    (lambda (inTriple)
        (letrec ((checkSides
            (lambda (lst)
                (cond 
                    ((null? lst) #t) ; Passed the check
                    ((or (not (number? (car lst))) (<= (car lst) 0)) #f) ; Invalid side
                    (else (checkSides (cdr lst)))
                )
            )   ))
            (checkSides inTriple)
        )
    )
)
;---------------------------------------------------------------------------
; SORTING PROCEDURE:
; (define sort-triple
; (lambda (triple) 
;     (cond 
;         ((< (car triple) (cadr triple) (caddr triple)) (list (car triple) (cadr triple) (caddr triple)))
;         ((< (car triple) (caddr triple) (cadr triple)) (list (car triple) (caddr triple) (cadr triple)))
;         ((< (cadr triple) (car triple) (caddr triple)) (list (cadr triple) (car triple) (caddr triple)))
;         ((< (cadr triple) (caddr triple) (car triple)) (list (cadr triple) (caddr triple) (car triple)))
;         ((< (caddr triple) (car triple) (cadr triple)) (list (caddr triple) (car triple) (cadr triple)))
;         (else (list (caddr triple) (cadr triple) (car triple)))
;     )
; )
; )

(define sort-all-triples
    (lambda (tripleList)
        (letrec ((sortTriple (lambda (triple) 
        (cond 
            ((< (car triple) (cadr triple) (caddr triple)) (list (car triple) (cadr triple) (caddr triple)))
            ((< (car triple) (caddr triple) (cadr triple)) (list (car triple) (caddr triple) (cadr triple)))
            ((< (cadr triple) (car triple) (caddr triple)) (list (cadr triple) (car triple) (caddr triple)))
            ((< (cadr triple) (caddr triple) (car triple)) (list (cadr triple) (caddr triple) (car triple)))
            ((< (caddr triple) (car triple) (cadr triple)) (list (caddr triple) (car triple) (cadr triple)))
            (else (list (caddr triple) (cadr triple) (car triple)))
        )   ))
            (sortAll (lambda (lst)
                (cond 
                    ((null? lst) '())
                    (else (cons (sortTriple (car lst)) (sortAll (cdr lst))))
                ))
            ))
            (sortAll tripleList)
        )
    )
)
;---------------------------------------------------------------------------
(define filter-triangle
    (lambda (tripleList)
        (cond 
            ((null? tripleList) '())
            ((triangle? (car tripleList))
                (cons (car tripleList) (filter-triangle (cdr tripleList))))
            (else (filter-triangle (cdr tripleList)))
        )
    )
)
(define triangle?
    (lambda (triple)
        (let (  (a (car triple))
                (b (cadr triple))
                (c (caddr triple))
            )
            (and (> a 0)
                (> b 0)
                (> c 0)
                (> (+ a b) c))
        )
    )
)
;---------------------------------------------------------------------------
(define filter-pythagorean
    (lambda (tripleList)
        (cond 
            ((null? tripleList) '())
            ((pythagorean-triangle? (car tripleList))
                (cons (car tripleList) (filter-pythagorean (cdr tripleList)))
            )
            (else (filter-pythagorean (cdr tripleList)))
        )
    )
)
(define pythagorean-triangle?
    (lambda (triple)
        (let (  (a (car triple))
                (b (cadr triple))
                (c (caddr triple))
            )
            (= (+ (* a a) (* b b)) (* c c))
        )
    )
)
;---------------------------------------------------------------------------
(define sort-area
    (lambda (tripleList)
        (sort tripleList (lambda (triple1 triple2)
                            (< (get-area triple1) (get-area triple2)))
        )
    )
)
(define get-area
    (lambda (triple)
        (let (  (a (car triple))
                (b (cadr triple))
                (c (caddr triple))
             )
            (/ (* a b) 2)
        )
    )
)

; |#|#|#|#|#|#|#|#|#|#|#|#|#|#|#| MAIN PROCEDURE |#|#|#|#|#|#|#|#|#|#|#|#|#|#|#| 

(define main-procedure
    (lambda (tripleList)
        (if (or (null? tripleList) (not (list? tripleList)))
            (error "ERROR305: the input should be a list full of triples")
            (if (check-triple? tripleList)
                (sort-area (filter-pythagorean (filter-triangle (sort-all-triples tripleList)) ))
                (error "ERROR305: the input should be a list full of triples")
            )
        )
    )
)
(define lst (list '(3 4 5) '(8 8 8) '(7 6 3) '(45 1 62) '(17 8 15) '(24 25 7)))
(display lst)