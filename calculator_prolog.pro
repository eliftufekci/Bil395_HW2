
calculator :-
    write('Simple Prolog Calculator'), nl,
    write('Enter expressions. Type "quit." to exit.'), nl,
    calculator_loop.

calculator_loop :-
    write('> '),
    read(Input),
    (Input == quit -> 
        write('Exiting calculator.'), nl
    ;   
        (process_input(Input),
         calculator_loop)
    ).

eval_expr(X + Y, Result) :-
    eval_expr(X, RX), 
    eval_expr(Y, RY), 
    Result is RX + RY.

eval_expr(X - Y, Result) :-
    eval_expr(X, RX), 
    eval_expr(Y, RY), 
    Result is RX - RY.

eval_expr(X * Y, Result) :-
    eval_expr(X, RX), 
    eval_expr(Y, RY), 
    Result is RX * RY.

eval_expr(X / Y, Result) :-
    eval_expr(X, RX), 
    eval_expr(Y, RY), 
    Y =\= 0, 
    Result is RX / RY.

eval_expr(X, X) :- number(X). 

process_input(Expression) :-
    eval_expr(Expression, Result),
    write('Result: '), write(Result), nl, !.

process_input(_) :-
    write('Error: Invalid expression'), nl.

:- calculator.
