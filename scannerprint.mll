{ open Printf }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| '('      { print_string "LPAREN " }
| ')'      { print_string "RPAREN " }
| '{'      { print_string "LBRACE " }
| '}'      { print_string "RBRACE " }
| '['      { print_string "LSQUARE " }
| ']'      { print_string "RSQUARE " }
| ';'      { print_string "SEMI " }
| ','      { print_string "COMMA " }
| '+'      { print_string "PLUS " }
| '-'      { print_string "MINUS " }
| '*'      { print_string "STAR " }
| '/'      { print_string "DIVIDE " }
| '%'      { print_string "MOD " }
| '&'      { print_string "ADDRESSOF " }
| '='      { print_string "ASSIGN " }
| '^'      { print_string "POW " }
| "%="     { print_string "MODASSIGN " }
| "=="     { print_string "EQ " }
| "!="     { print_string "NEQ " }
| '<'      { print_string "LT " }
| "<="     { print_string "LEQ " }
| '>'      { print_string "GT " }
| ">="     { print_string "GEQ " }
| "&&"     { print_string "AND " }
| "||"     { print_string "OR " }
| '!'      { print_string "NOT " }
| "if"     { print_string "IF " }
| "else"   { print_string "ELSE " }
| "for"    { print_string "FOR " }
| "while"  { print_string "WHILE " }
| "do"     { print_string "DO " }
| "break"  { print_string "BREAK " }
| "continue" { print_string "CONTINUE " }
| "return" { print_string "RETURN " }
| "int"    { print_string "INT " }
| "void"   { print_string "VOID " }
| "char"   { print_string "CHAR " }
| "NULL"   { print_string "NULL " }
| "stone"  { print_string "STONE " }
| "mint"   { print_string "MINT " }
| "point"  { print_string "POINT " }
| "curve"  { print_string "CURVE " }
| '~'      { print_string "INF " }
| "access" { print_string "ACCESS " }
| '\''     { print_string "SGLQUOTE " }
| '"'      { print_string "DBLQUOTE " }
| ['0'-'9']+ { print_string "LITERAL " }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* { print_string "ID " }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }

{
  let main () =
    let lexbuf = Lexing.from_channel stdin in
    try
        while true do
            ignore (token lexbuf)
        done
    with _ -> print_string "EOF\n"
  let _ = Printexc.print main ()

}

