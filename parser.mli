type token =
  | SEMI
  | COMMA
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | LSQUARE
  | RSQUARE
  | PLUS
  | MINUS
  | STAR
  | DIVIDE
  | MOD
  | ASSIGN
  | NOT
  | POW
  | ADDRESSOF
  | MODASSIGN
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | AND
  | OR
  | RETURN
  | IF
  | ELSE
  | FOR
  | WHILE
  | DO
  | BREAK
  | CONTINUE
  | INT
  | CHAR
  | VOID
  | NULL
  | STONE
  | MINT
  | CURVE
  | POINT
  | INF
  | ACCESS
  | LITERAL of (int)
  | ID of (string)
  | STRING of (string)
  | SGLQUOTE
  | DBLQUOTE
  | EOF

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
