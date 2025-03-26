use std::collections::HashMap;
use std::io::{self, Write};

#[derive(Debug, Clone)]
enum Token {
    Number(f64),
    Plus,
    Minus,
    Multiply,
    Divide,
    LeftParen,
    RightParen,
    Identifier(String),
    Assign,
}

fn tokenize(expr: &str) -> Vec<Token> {
    let mut tokens = Vec::new();
    let mut chars = expr.chars().peekable();
    
    while let Some(&ch) = chars.peek() {
        match ch {
            '0'..='9' => {
                let mut num = String::new();
                while let Some(&c) = chars.peek() {
                    if c.is_digit(10) || c == '.' {
                        num.push(c);
                        chars.next();
                    } else {
                        break;
                    }
                }
                tokens.push(Token::Number(num.parse().unwrap()));
            }
            '+' => { tokens.push(Token::Plus); chars.next(); }
            '-' => { tokens.push(Token::Minus); chars.next(); }
            '*' => { tokens.push(Token::Multiply); chars.next(); }
            '/' => { tokens.push(Token::Divide); chars.next(); }
            '(' => { tokens.push(Token::LeftParen); chars.next(); }
            ')' => { tokens.push(Token::RightParen); chars.next(); }
            '=' => { tokens.push(Token::Assign); chars.next(); }
            'a'..='z' | 'A'..='Z' => {
                let mut ident = String::new();
                while let Some(&c) = chars.peek() {
                    if c.is_alphanumeric() || c == '_' {
                        ident.push(c);
                        chars.next();
                    } else {
                        break;
                    }
                }
                tokens.push(Token::Identifier(ident));
            }
            ' ' => { chars.next(); }
            _ => panic!("Unexpected character: {}", ch),
        }
    }
    tokens
}

fn precedence(op: &Token) -> i32 {
    match op {
        Token::Plus | Token::Minus => 1,
        Token::Multiply | Token::Divide => 2,
        _ => 0,
    }
}

fn to_postfix(tokens: Vec<Token>) -> Vec<Token> {
    let mut output = Vec::new();
    let mut operators = Vec::new();
    
    for token in tokens {
        match token {
            Token::Number(_) | Token::Identifier(_) => output.push(token),
            Token::Plus | Token::Minus | Token::Multiply | Token::Divide => {
                while let Some(top) = operators.last() {
                    if precedence(top) >= precedence(&token) {
                        output.push(operators.pop().unwrap());
                    } else {
                        break;
                    }
                }
                operators.push(token);
            }
            Token::LeftParen => operators.push(token),
            Token::RightParen => {
                while let Some(top) = operators.pop() {
                    if let Token::LeftParen = top {
                        break;
                    }
                    output.push(top);
                }
            }
            _ => {}
        }
    }
    while let Some(op) = operators.pop() {
        output.push(op);
    }
    output
}

fn evaluate_postfix(tokens: Vec<Token>, variables: &mut HashMap<String, f64>) -> f64 {
    let mut stack = Vec::new();
    for token in tokens {
        match token {
            Token::Number(n) => stack.push(n),
            Token::Identifier(ref name) => {
                if let Some(&val) = variables.get(name) {
                    stack.push(val);
                } else {
                    panic!("Undefined variable: {}", name);
                }
            }
            Token::Plus => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a + b);
            }
            Token::Minus => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a - b);
            }
            Token::Multiply => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a * b);
            }
            Token::Divide => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a / b);
            }
            _ => {}
        }
    }
    stack.pop().unwrap()
}

fn evaluate(expression: &str, variables: &mut HashMap<String, f64>) -> f64 {
    let tokens = tokenize(expression);
    let postfix = to_postfix(tokens);
    evaluate_postfix(postfix, variables)
}

fn main() {
    let mut variables = HashMap::new();
    loop {
        print!("> ");
        io::stdout().flush().unwrap();
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        let input = input.trim();
        if input.is_empty() { continue; }
        if input == "exit" { break; }
        let result = evaluate(input, &mut variables);
        println!("= {}", result);
    }
}
