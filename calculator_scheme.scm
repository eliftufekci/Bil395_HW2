(define variables '())

(define (lookup-var name)
  (let ((entry (assoc name variables)))
    (if entry
        (cdr entry)
        #f)))  

(define (set-var name value)
  (if (lookup-var name)
      (set! variables (cons (cons name value) (assq-delete-all name variables))))
  (set! variables (cons (cons name value) variables)))

(define (evaluate expr)
  (cond

    ((number? expr) expr)


    ((symbol? expr) 
     (or (lookup-var expr)
         (begin (display "Error: Undefined variable ") (display expr) (newline) 0)))

    ((and (list? expr) (eq? (car expr) 'set))
     (if (and (= (length expr) 3) (symbol? (cadr expr)))
         (begin
           (set-var (cadr expr) (evaluate (caddr expr)))
           (lookup-var (cadr expr)))
         (begin (display "Error: Invalid assignment syntax") (newline) 0)))

    ((list? expr)
     (let ((op (car expr))
           (args (map evaluate (cdr expr))))
       (cond
         ((eq? op '+) (apply + args))
         ((eq? op '-) (apply - args))
         ((eq? op '*) (apply * args))
         ((eq? op '/) (if (not (zero? (cadr args)))
                          (apply / args)
                          (begin (display "Error: Division by zero") (newline) 0)))
         (else (begin (display "Error: Unknown operator ") (display op) (newline) 0)))))

    (else (begin (display "Error: Invalid expression") (newline) 0))))

(define (repl)
  (display "> ")
  (let ((input (read)))
    (unless (eq? input 'exit)
      (display "= ") 
      (display (evaluate input)) (newline)
      (repl))))

(repl)