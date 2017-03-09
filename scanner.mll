  (* Ocamllex scanner for MicroC *)

{ open Parser }

(* why are some string and some chars LT, GT eg *)

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['      { LSQUARE }
| ']'      { RSQUARE }
| ';'      { SEMI }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { STAR }
| '/'      { DIVIDE }
| '%'      { MOD }
| '='      { ASSIGN }
| '^'      { POW }
| "%="     { MODASSIGN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| '>'     { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| '!'      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "do"     { DO }
| "break"  { BREAK }
| "continue" { CONTINUE }
| "return" { RETURN }
| "int"    { INT }
| "void"   { VOID }
| "char"   { CHAR }
| "NULL"   { NULL }
| "stone"  { STONE }
| "mint"   { MINT }
| "point"  { POINT }
| "curve"  { CURVE }
| '~'      { INF }
| "access" { ACCESS }
| '\''     { SGLQUOTE }
| '"'      { DBLQUOTE }
| ['0'-'9']+ as lxm { LITERAL(int_of_string lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }
