/* Ocamlyacc parser for C%, after that for MicroC */

%{
open Ast
%}

%token SEMI COMMA COLON LPAREN RPAREN LBRACE RBRACE LSQUARE RSQUARE
%token PLUS MINUS STAR DIVIDE POW MOD ASSIGN NOT /*NEG*/ /* minus is neg, star is times */
%token MODASSIGN /* star is deref*/
%token EQ NEQ LT LEQ GT GEQ AND OR
%token RETURN IF ELSE FOR WHILE DO BREAK CONTINUE
%token INT CHAR VOID POINTER NULL
%token STONE MINT CURVE POINT INF ACCESS
%token <int> LITERAL   //need string literals
%token <string> ID
%token SGLQUOTE DBLQUOTE
%token EOF

//COMMA?
%nonassoc NOELSE
%nonassoc ELSE
%right MODASSIGN ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%right ACCESS
%left STAR DIVIDE MOD //star is times
%left POW
%right NOT NEG ADDRESSOF DEREF /* minus is neg, mod is addof, star is deref */

%start program
%type <Ast.program> program

%%

program:
  decls EOF { $1 }

decls:
   /* nothing */ { [], [] }
 | decls vdecl { ($2 :: fst $1), snd $1 }
 | decls fdecl { fst $1, ($2 :: snd $1) }

fdecl:
   typ ID LPAREN formals_opt RPAREN LBRACE vdecl_list stmt_list RBRACE
     { { typ = $1;
     fname = $2;
     formals = $4;
     locals = List.rev $7;
     body = List.rev $8 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2)] }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

typ:
    INT { Int }
  | CHAR { Char }
  | VOID { Void }
  | STONE { Stone }
  | MINT { Mint }
  | CURVE { Curve }
  | POINT { Point }
  | typ POINTER { Pointer($1) }  // unclear if this is a proper declaration

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
   typ ID SEMI { ($1, $2) }

stmt_list:
  stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }   /*expr_opt here instead of nullstmt maybe*/
  | RETURN SEMI { Return Noexpr }
  | RETURN expr SEMI { Return $2 }
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN expr_opt SEMI expr_opt SEMI expr_opt RPAREN stmt   /* made expr2 optional */
     { For($3, $5, $7, $9) }
  | WHILE LPAREN expr RPAREN stmt { While($3, $5) }
  | DO stmt WHILE LPAREN expr RPAREN { DoWhile($2, $5) }     /* ADDED */
  | BREAK SEMI { Break }    /* ADDED */
  | CONTINUE SEMI { Continue } /* added */
  | SEMI { NullStmt } /* ADDED - unclear if could be Noexpr */

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL          { Literal($1) }
  | ID               { Id($1) }
  | expr PLUS   expr { Binop($1, Add,   $3) }
  | expr MINUS  expr { Binop($1, Sub,   $3) }
  | expr STAR  expr { Binop($1, Mult,  $3) } //star is times
  | expr DIVIDE expr { Binop($1, Div,   $3) }
  | expr POW    expr { Binop($1, Pow,   $3) }
  | expr EQ     expr { Binop($1, Equal, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Less,  $3) }
  | expr LEQ    expr { Binop($1, Leq,   $3) }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | MINUS expr %prec NEG { Unop(Neg, $2) } /* second minus is neg */
  | NOT expr         { Unop(Not, $2) }
  | lval ASSIGN expr   { Assign($1, $3) } //changed ID to lval
  | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN { $2 }
  | NULL { Null }   /* Added all after this line in expr */
  | DEREF expr       { Unop(Deref, $2) } // star is deref
  | ADDRESSOF lval   { Unop(Addrof, $2) }  /* must be an lvalue */
  | expr MOD expr { Binop($1, Mod, $3) }
  | lval MODASSIGN expr  { ModAssign($1, $3) }
  | DBLQUOTE ID DBLQUOTE { String($2) } /* string literal */
  | SGLQUOTE ID SGLQUOTE { Char($2) } /* char literal */
  | LBRACE actuals_list RBRACE  { Constr($2) } /* construct mints/stones */
  | ID LSQUARE expr RSQUARE { Subscript($1, $3) }

/* Added -- unclear if in grammar or semantic checking ? */
/* Removed most lval in favor of handling during semantic checking */
/* TODO: veryify */
lval:
      ID                     { Id($1) }  /* can't be a function pointer ?? */
//    | LPAREN lval RPAREN     { $2 }
//    | STAR expr             { Deref($2) } // star is deref

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }
