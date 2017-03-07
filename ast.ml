(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Pow | Mod

type uop = Neg | Not | Deref | AddrOf | Access

type typ = Int | Char | Stone | Mint | Curve | Point | Void | Pointer of typ

type bind = typ * string

type expr =
    Literal of int
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
  | Noexpr    (* not Null? *)
  | Null
  | ModAssign of string * expr
  | String of string
  | Ch of string (* Maybe change back to char *)
  | Constr of expr list
  | Subscript of string * expr
  | Inf

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt   (* need to account for optional exprs? *)
  | While of expr * stmt
  | DoWhile of stmt * expr
  | Break
  | Continue
  | NullStmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Pow -> "**"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"
  | Deref -> "*"
  | AddrOf -> "&"
  | Access -> "access"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""
  | Null -> "NULL"  (* pointer to zero *)
  | Inf -> "Inf"
  | ModAssign(v, e) -> v ^ " %= " ^ string_of_expr e
  | String(s) -> s
  | Ch (c) -> c
  | Constr(el) -> "{" ^ String.concat ", " (List.map string_of_expr el) ^ "}"
  | Subscript(s, e) -> s ^ "[" ^ string_of_expr e ^ "]"

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s
  | DoWhile(s, e) -> "do { \n" ^ string_of_stmt s ^ "\n} while (" ^ string_of_expr e ^ ")\n"
  | Break -> "break;\n"
  | Continue -> "continue;\n"
  | NullStmt -> ";\n"

let rec string_of_typ = function
    Int -> "int"
  | Char -> "char"
  | Stone -> "stone"
  | Mint -> "mint"
  | Curve -> "curve"
  | Point -> "point"
  | Void -> "void"
  | Pointer _ as t -> "pointer " ^ string_of_typ(t)

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)
