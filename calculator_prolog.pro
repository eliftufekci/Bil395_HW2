% Simple Interactive Calculator in Prolog with Parentheses Support

calculator :-
    write('Simple Prolog Calculator'), nl,
    write('Enter expressions. Type "quit." to exit.'), nl,
    calculator_loop.

% Calculator input loop
calculator_loop :-
    write('> '),
    read(Input),
    (Input == quit -> 
        write('Exiting calculator.'), nl
    ;   
        (process_input(Input),
         calculator_loop)
    ).

% Process and evaluate expressions with parentheses support
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

eval_expr(X, X) :- number(X). % Base case for numbers

% Process input and display result
process_input(Expression) :-
    eval_expr(Expression, Result),
    write('Result: '), write(Result), nl, !.

process_input(_) :-
    write('Error: Invalid expression'), nl.

% Start the calculator directly in the top level
:- calculator.
