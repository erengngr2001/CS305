(define get-operator (lambda (op-symbol env)
    (cond
        ((eq? op-symbol '+) +)
        ((eq? op-symbol '*) *)
        ((eq? op-symbol '-) -)
        ((eq? op-symbol '/) /)
        (else (err env))
    ))
)

(define get-value (lambda (var env)
    (cond 
        ( (null? env) (err env) )
        ( (eq? var (caar env)) (cdar env))
        ( else (get-value var (cdr env)))
    ))
)

(define extend-env (lambda (var val old-env)
      (cons (cons var val) old-env)
    )
)

(define define-expr? (lambda (e)
       (and (list? e) (= (length e) 3) (eq? (car e) 'define) (symbol?(cadr e)))
    )
)

(define if-stmt? (lambda (e)
        (and (= (length e) 4) (eq? (car e) 'if) (expr? (cadr e)) (expr? (caddr e)) (expr? (cadddr e)) )
    )
)

(define calc? (lambda (e)
        (and (> (length e) 1) (or (eq? (car e) '+) (eq? (car e) '-) (eq? (car e) '*) (eq? (car e) '/)) ) ; BUNUN EDGE CASELERİ PATLIYO
    )
)

(define cond-stmt? (lambda (e)
        (and (> (length e) 2) (eq? (car e) 'cond) (cond-list? (cdr e)) )
    )
)
; Helper func for cond-stmt?
(define cond-list? (lambda (e)
        (cond 
            (( and (list? (car e)) (> (length e) 1) (else-stmt? (car e)) ) #f )
            (( and (list? (car e)) (= (length e) 1) (else-stmt? (car e)) ) #t )
            (( and (list? (car e)) (= (length e) 1) (not (else-stmt? (car e))) ) #f )
            ;(( and (expr? (car (car e))) (expr? (cadr (car e))) ) (cond-list? (cdr e))  ) ALTTAKİ SATIRI YAZINCA BU GEREKSİZ OLDU
            (( and (list? (car e)) (cond? (car e)) ) (cond-list? (cdr e))  )
            (else #f) ;empty set durumu
        )
    )
)
; Helper func for cond-list?
(define cond? (lambda (e)
        (and (= (length e) 2) (expr? (car e)) (expr? (cadr e)) )
    )
)
; Helper func for cond-list?
(define else-stmt? (lambda (e)
        (and (= (length e) 2) (eq? (car e) 'else) (expr? (cadr e)) )
    )
)

(define let-stmt? (lambda (e)
        (and (= (length e) 3) (eq? (car e) 'let) (var-bind-list? (cadr e)) (expr? (caddr e)) ) ;(unique-vars? (cadr e)) )
    )
)
(define letstar-stmt? (lambda (e)
        (and (= (length e) 3) (eq? (car e) 'let*) (var-bind-list? (cadr e)) (expr? (caddr e)) ) ;(unique-vars? (cadr e)) )
    )
)
; Helper func for let-stmt?
; (define unique-vars? (lambda (e)
;         (define lst '())
;         ; (cond 
;         ;     ((null? e) #t ) 
;         ;     (else (add-to-lst e lst) )    
;         ; )        
;         ; (cond 
;         ;     ((not (contains? (car (car e)) lst)) (unique-vars? (cdr e)) )
;         ;     (else #f )
;         ; )

;         (if
;             (null? e) 
;             (#t)
;             (
;                 (add-to-lst e lst)
;                 (cond 
;                     ((not (contains? (car (car e)) lst)) (unique-vars? (cdr e)) )
;                     (else #f )
;                 )
;             )       
;         )
;     )
; )
; ; Helper func for unique-vars?
; (define add-to-lst (lambda (e lst)

;     )
; )
; Helper func for let-stmt?
(define var-bind-list? (lambda (e)
        (cond 
            ((eq? e '()) #t )
            ((var-binding? (car e)) (var-bind-list? (cdr e)) )
            (else #f)
        )
    )
) 
; Helper func for var-bind-stmt?
(define var-binding? (lambda (e)
        (and (list? e) (= (length e) 2) (symbol? (car e)) (expr? (cadr e)) )
    )
)

(define expr? (lambda (e)
        (or (number? e) (symbol? e) (if-stmt? e) (calc? e) (cond-stmt? e) (let-stmt? e) (letstar-stmt? e) )
    )
)

(define my-if (lambda (e env)
        (if 
            (not (= 0 (s6 (cadr e) env)) )
            (s6 (caddr e) env)
            (s6 (cadddr e) env)
        )
    )
)

(define my-calc (lambda (e env)
        (let (
            (operator (get-operator (car e) env ))
            (operands (map s6 (cdr e) (make-list (length (cdr e) ) env )))
            )
            
            (apply operator operands)
        )
    )
)

(define my-cond (lambda (e env)
        (if 
            (not (eq? (car (car e)) 'else))
            (   
                (lambda () (if 
                    (not (= 0 (s6 (car (car e)) env)) )
                    (s6 (cadr (car e)) env)
                    (my-cond (cdr e) env)
                ))
            )
            (s6 (cadr (car e)) env)
        )
    )
)

(define my-let (lambda (e env)
        ; (define temp-env env)
        ; (define binding-list (cadr e))
        ; (cond
        ;     ((null? binding-list) (s6 (caddr e) env) ) ; binding list boşsa direkt expressionu çalıştır
        ;     ((var-defined? (car (car binding-list)) env) () ) ; binding list doluysa ve variable define edilmişse --> variableın değerini güncelle
        ;     (else (extend-env (car ))) ; binding list doluysa ama variable define edilmemişse --> variable ve değerini environmenta ekle
        ; )
    
        (let*
            ((vars (map s6 (map cadr (cadr e)) (make-list (length (map cadr (cadr e))) env)))
            (tempenv (append ( map cons (map car (cadr e)) vars) env)))
            (s6 (caddr e) tempenv)
        )    
    )
)

(define my-letstar (lambda (e env)
        (cond
            ((eq? (length (cadr e)) 0) (s6 (list 'let '() (caddr e)) env))
            ((eq? (length (cadr e)) 1) (s6 (list 'let (cadr e) (caddr e)) env))
            (else
                (let*
                    ((var (s6 (car (cdaadr e)) env))
                        (tempenv (cons (cons (caaadr e) var) env)))
                        (s6 (list 'let* (cdadr e) (caddr e)) tempenv)
                )
            )
        )
    )
)
; Helper func for my-let
; (define var-defined? (lambda (ident env)
;         (cond
;             ((null? env) #f )
;             ((eq? (cadr e) (car (car env))) #t )
;             ((not (eq? (cadr e)) (car (car env))) (var-defined? ident (cdr env)) )
;             (else )
;         )
;     )
; )
; Helper func for my-let
; parametreler --> (car binding-list) + temp-env 
; binding --> (x 3)
; env --> (x,5)
; temp-env --> (x,5)

; (define update-temp-env (lambda (binding temp-env)
;         (cond
;             ((null? env)  )
;             ((eq? (cadr e) (car (car env))) #t )
;             ((not (eq? (cadr e)) (car (car env))) (var-defined? ident (cdr env)) )
;             (else )
;         )
;     )
; )

(define s6 (lambda (e env)
    (cond
        ( (number? e) e)
        ( (symbol? e) (get-value e env))
        ( (not (list? e)) (err env))
        ( (not (> (length e) 1)) (err env))
        ( (if-stmt? e) (my-if e env))
        ( (cond-stmt? e) (my-cond (cdr e) env))
        ( (let-stmt? e) (my-let e env))
        ( (letstar-stmt? e) (my-letstar e env))
        ( (calc? e) (my-calc e env))
        ( else (err env))
    ))
)

(define err (lambda (env)
        (display "ERROR")
        (newline)
        (newline)
        (repl env)
    )
)

(define repl (lambda (env)
    (let* (
        (dummy1 (display "cs305> "))
        (expr (read))
        (new-env (if (define-expr? expr) 
                    (extend-env (cadr expr) (s6 (caddr expr) env) env)
                    env)
        )
        (val (cond 
                ((define-expr? expr) (cadr expr))
                (else (s6 expr env))
            )
        )
        (dummy2 (display "cs305: "))
        (dummy3 (display val))
        (dummy4 (newline))
        (dummy5 (newline))
        )
        (repl new-env)
    ))
)

(define cs305 (lambda () (repl '())))