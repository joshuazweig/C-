(* Semantic checking for the MicroC compiler *)

open Ast

module StringMap = Map.Make(String)

(* Semantic checking of a program. Returns void if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each function *)


let check (globals, functions) =

  (* Raise an exception if the given list has a duplicate *)
  let report_duplicate exceptf list =
    let rec helper = function
	n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
      | _ :: t -> helper t
      | [] -> ()
    in helper (List.sort compare list)
  in

  (* Raise an exception if a given binding is to a void type *)
  let check_not_void exceptf = function
      (Void, n) -> raise (Failure (exceptf n))
    | _ -> ()
  in
  
  (* Raise an exception of the given rvalue type cannot be assigned to
     the given lvalue type *)
  let check_assign lvaluet rvaluet err = 
     if lvaluet = rvaluet then lvaluet else raise err
  in
   
  (**** Checking Global Variables ****)

  List.iter (check_not_void (fun n -> "illegal void global " ^ n)) globals;
   
  report_duplicate (fun n -> "duplicate global " ^ n) (List.map snd globals);

  (**** Checking Functions ****)

  if List.mem "printf" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function printf may not be defined")) else ();
  
  if List.mem "access" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function access may not be defined")) else ();
 
  if List.mem "scanf" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function scanf may not be defined")) else ();
  
  if List.mem "malloc" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function malloc may not be defined")) else ();

  if List.mem "free" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function free may not be defined")) else ();

  report_duplicate (fun n -> "duplicate function " ^ n)
    (List.map (fun fd -> fd.fname) functions);

  (* Function declaration for a named function *)
  let built_in_decls =  List.fold_left (fun map (name, attr) -> StringMap.add
  name attr map) StringMap.empty [ 
       ("printf", { typ = Void; fname = "printf"; formals = []; 
       (* change formals to be variadic? Right now, this is fixed by just not 
       comparing formals and actuals list if the name of the function is printf  *)
       locals = []; body = [] });

       ("print_stone", { typ = Int; fname = "print_stone"; formals = [(Stone,
       "x")]; locals = []; body = [] });
       ("print_mint", { typ = Int; fname = "print_mint"; formals = [(Mint,
       "x")]; locals = []; body = [] });
       ("print_point", { typ = Int; fname = "print_point"; formals =
           [(Pointer(Point), "P")]; locals = []; body = [] });
       ("print_curve", { typ = Int; fname = "print_curve"; formals =
           [(Pointer(Curve),
       "E")]; locals = []; body = [] });
       ("scanf", { typ = Void; fname = "scanf"; formals = [(Pointer(Char), "x")]; 
       locals = []; body = [] });
       ("malloc", { typ = Pointer(Char); fname = "malloc"; formals = [(Int, "x")];
       locals = []; body = [] });
       ("free", { typ = Void; fname = "free"; formals = [(Pointer(Char), "x")];
       locals = []; body = [] })
       ] 
       (* Can only malloc char pointers, best way to generalize? *)
   in
     
  let function_decls = List.fold_left (fun m fd -> StringMap.add fd.fname fd m)
                         built_in_decls functions
  in

  let function_decl s = try StringMap.find s function_decls
       with Not_found -> if s = "main" then raise (Failure ("main function must be defined"))
       else raise (Failure ("unrecognized function " ^ s))
  in

  let _ = function_decl "main" in (* Ensure "main" is defined *)
  (* Note: This prints a weird error message in the case main isn't defined.
   * Maybe change it? (This is edwards' code) *)

  let check_function func =

    List.iter (check_not_void (fun n -> "illegal void formal " ^ n ^
      " in " ^ func.fname)) func.formals;

    report_duplicate (fun n -> "duplicate formal " ^ n ^ " in " ^ func.fname)
      (List.map snd func.formals);

    List.iter (check_not_void (fun n -> "illegal void local " ^ n ^
      " in " ^ func.fname)) func.locals;

    report_duplicate (fun n -> "duplicate local " ^ n ^ " in " ^ func.fname)
      (List.map snd func.locals);


    let type_of_identifier s lookup_table =
      try StringMap.find s lookup_table
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    let type_of_pointer t ex = match t with
        Pointer(_ as x) -> x;
      | _ -> raise (Failure ("non-pointer expression " ^ string_of_expr ex ^ 
      " is being used as a pointer"))
    in

    (* Return the type of an expression or throw an exception *)
    let rec expr table = function
        Inf -> Point
      | Null -> Pointer(Void)
      | Literal _ -> Int
      | Id s -> type_of_identifier s table
      | Ch _ -> Char
      | String _ -> Pointer(Char)
      | Subscript(a, i)  as e -> if (expr table i) = Int then (type_of_pointer
      (type_of_identifier a table) e) else raise (Failure ("use of non-integer type as index in " ^
        string_of_expr e))
      | Binop(e1, op, e2) as e -> let t1 = expr table e1 and t2 = expr table e2 in
	(match op with
          Add | Sub when t1 = Pointer(Point) && t2 = Pointer(Point) ->
              Pointer(Point)
        | Mult when t1 = Stone && t2 = Pointer(Point) -> Pointer(Point)
        | Add | Sub | Mult | Div | Pow when t1 = Int && t2 = Int -> Int
        | Add | Sub | Mult | Div | Pow when t1 = Stone && t2 = Stone -> Stone
        | Add | Sub | Mult | Pow when t1 = Mint && t2 = Mint -> Mint
        | Pow when t1 = Mint && t2 = Stone -> Mint
	| Equal | Neq when t1 = t2 -> Int  (* might want to extend this to allow
        e.g., t1 and t2 both integer types so one can do stone=int *)
	| Less | Leq | Greater | Geq when t1 = Int && t2 = Int -> Int
  | Equal | Neq | Less | Leq | Greater | Geq when t1 = Stone && t2 = Stone -> Int
        | _ -> raise (Failure ("illegal binary operator " ^
              string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
              string_of_typ t2 ^ " in " ^ string_of_expr e))
        )
      | Unop(op, e) as ex -> let t = expr table e in
	 (match op with
	   Neg when t = Int -> Int
         | Neg when t = Stone -> Stone
         | Neg when t = Mint -> Mint
         | Neg when t = Pointer(Point) -> Pointer(Point)
         | Neg when t = Char -> Char
         | Not when t = Int -> Int  
         | Deref -> type_of_pointer t e
         | AddrOf -> Pointer(t)
         | Access when t = Mint || t = Point || t = Curve -> Pointer(Stone)
         | _ -> raise (Failure ("illegal unary operator " ^ string_of_uop op ^
	  		   string_of_typ t ^ " in " ^ string_of_expr ex)))
      | Construct2(e1, e2) -> let t1 = expr table e1 and t2 = expr table e2 in
        (match (t1, t2) with
          (Stone, Stone) -> Mint
        | (Mint, Mint)   -> Pointer(Curve)
        | _ -> raise (Failure ("illegal constructor type pair (" ^ string_of_typ t1 
        ^ "," ^ string_of_typ t2 ^ ")")))
      | Construct3(e1, e2, e3) -> let t1 = expr table e1 and t2 = expr table e2
  and t3 = expr table e3 in
        (match (t1, t2, t3) with
        | (Pointer(Curve), Stone, Stone) -> Pointer(Point)
        | _ -> raise (Failure ("illegal constructor type pair (" ^ string_of_typ t1 
        ^ "," ^ string_of_typ t2 ^ "," ^ string_of_typ t3 ^ ")")))
      | Noexpr -> Void

      (* Definitely need to change this to support things which return lvalues,
       * e.g. dereferencing *)
      | Assign(var, e) as ex -> let lt = type_of_identifier var table
                                and rt = expr table e in
        if (lt, rt) = (Stone, Pointer(Char)) then Stone else
        check_assign lt rt (Failure ("illegal assignment " ^ string_of_typ lt ^
				     " = " ^ string_of_typ rt ^ " in " ^ 
				     string_of_expr ex))
      | ModAssign(var, e) as ex -> let lt = type_of_identifier var table
                                   and rt = expr table e in
        (match (lt, rt) with
          ((Int|Stone) as t, (Int|Stone)) -> t
        | _ -> raise (Failure ("illegal use of %= with types " ^ string_of_typ
        lt ^ " and " ^ string_of_typ rt ^ " in " ^ string_of_expr ex)))
      | Call(fname, actuals) as call -> let fd = function_decl fname in
         if fname = "printf" 
           then
               let _ = List.iter (fun e -> ignore(expr table e)) actuals in Void
         else
           if List.length actuals != List.length fd.formals 
             then
             raise (Failure ("expecting " ^ string_of_int
               (List.length fd.formals) ^ " arguments in " ^ string_of_expr call))
           else
               let _ = List.iter2 (fun (ft, _) e -> let et = expr table e in
                ignore (check_assign ft et
                (Failure ("illegal actual argument found " ^ string_of_typ et ^
                " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr call))))
             fd.formals actuals
             in
           fd.typ
    in

    let check_int_expr table e = if expr table e != Int
     then raise (Failure ("expected integer expression in " ^ string_of_expr e))
     else () in

    (* Verify a statement or throw an exception *)
    let rec stmt table in_loop = function
        Block (vl, sl) -> let rec check_block block_table = function
           [Return _ as s] -> stmt block_table in_loop s
         | Return _ :: _ -> raise (Failure "nothing may follow a return")
         | (Block (_, _) as b) :: ss -> stmt block_table in_loop b; check_block
         block_table ss
         | s :: ss -> stmt block_table in_loop s ; check_block block_table ss
         | [] -> ()
        in 
          List.iter (check_not_void (fun n -> "illegal void local " ^ n ^
            " in " ^ func.fname)) vl;
            (* check for void type *)

          report_duplicate (fun n -> "duplicate local " ^ n ^ " in " ^ func.fname)
            ((List.map snd vl) );
            (* check for duplicate names in that scope *)

          let new_table = List.fold_left (fun m (t, n) -> StringMap.add n t
            m) table vl in
          
          check_block new_table sl
            (* check the block with new lookup table *)

      | Expr e -> ignore (expr table e)
      | Return e -> let t = expr table e in if t = func.typ then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.typ ^ " in " ^ string_of_expr e))
           
      | If(p, b1, b2) -> check_int_expr table p; stmt table false b1; stmt table false b2 
      | For(e1, e2, e3, st) -> ignore (expr table e1); check_int_expr table e2;
                               ignore (expr table e3); stmt table true st
      | While(p, s) -> check_int_expr table p; stmt table true s
      | DoWhile(s, p) -> stmt table true s; check_int_expr table p
      | Break -> if in_loop then () else
          raise (Failure ("break statement found outside of a loop context"))
      | Continue -> if in_loop then () else
          raise (Failure ("continue statement found outside of a loop context"))
      | NullStmt -> ()
    in

    (* Type of each variable (global, formal, or local *)
    let table = List.fold_left (fun m (t, n) -> StringMap.add n t m)
      StringMap.empty (globals @ func.formals @ func.locals) in
    
    stmt table false (Block ([], func.body))
   
  in
  List.iter check_function functions
