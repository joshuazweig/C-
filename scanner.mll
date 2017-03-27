  (* Ocamllex scanner for MicroC *)
{ open Parser 
    module B = Buffer }

(* why are some string and some chars LT, GT eg *)

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| "//"     { comment2 lexbuf }
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
| '&'      { ADDRESSOF }
| '='      { ASSIGN }
| '^'      { POW }
| "%="     { MODASSIGN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| '>'      { GT }
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
| "'"      { SGLQUOTE }
| '"'      { STRING (build_str (B.create 100) lexbuf) }
| ['0'-'9']+ as lxm { LITERAL(int_of_string lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }

and comment2 = parse
  '\n' { token lexbuf }
| _    { comment2 lexbuf }

and build_str sb = parse
 | '"'      { B.contents sb }
 | '\\''\\' { B.add_char sb '\\';  build_str sb lexbuf }
 | '\\''"'  { B.add_char sb '"';   build_str sb lexbuf }
 | '\\''\'' { B.add_char sb '\'';  build_str sb lexbuf }
 | '\\''n'  { B.add_char sb '\n';  build_str sb lexbuf }
 | '\\''r'  { B.add_char sb '\r';  build_str sb lexbuf }
 | '\\''t'  { B.add_char sb '\t';  build_str sb lexbuf }
 | _ as t   { B.add_char sb t;     build_str sb lexbuf }
