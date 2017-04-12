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
     if lvaluet == rvaluet then lvaluet else raise err
  in
   
  (**** Checking Global Variables ****)

  List.iter (check_not_void (fun n -> "illegal void global " ^ n)) globals;
   
  report_duplicate (fun n -> "duplicate global " ^ n) (List.map snd globals);

  (**** Checking Functions ****)

  if List.mem "printf" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function printf may not be defined")) else ();
  
  if List.mem "access" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function access may not be defined")) else ();
 

  report_duplicate (fun n -> "duplicate function " ^ n)
    (List.map (fun fd -> fd.fname) functions);

  (* Function declaration for a named function *)
  let built_in_decls =  StringMap.add "printf"
     { typ = Void; fname = "printf"; formals = []; (* change formals
     to be variadic? Right now, this is fixed by just not comparing formals and
     actuals list if the name of the function is printf  *)
       locals = []; body = [] } StringMap.empty
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

    (* Type of each variable (global, formal, or local *)
    let symbols = List.fold_left (fun m (t, n) -> StringMap.add n t m)
	StringMap.empty (globals @ func.formals @ func.locals )
    in

    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    let type_of_pointer t ex = match t with
        Pointer(_ as x) -> x;
      | _ -> raise (Failure ("non-pointer expression " ^ string_of_expr ex ^ 
      " is being used as a pointer"))
    in

    (* Return the type of an expression or throw an exception *)
    let rec expr = function
        Inf -> Point
      | Null -> Pointer(Void)
      | Literal _ -> Int
      | Id s -> type_of_identifier s
      | Ch _ -> Char
      | String _ -> Pointer(Char)
      | Subscript(a, i)  as e -> if (expr i) = Int then (type_of_pointer
      (type_of_identifier a) e) else raise (Failure ("use of non-integer type as index in " ^
        string_of_expr e))
      | Binop(e1, op, e2) as e -> let t1 = expr e1 and t2 = expr e2 in
	(match op with
          Add | Sub when t1 = Point && t2 = Point -> Point
        | Add | Sub | Mult | Div | Pow when t1 = Int && t2 = Int -> Int
        | Add | Sub | Mult | Div | Pow when t1 = Stone && t2 = Stone -> Stone
        | Add | Sub | Mult | Pow when t1 = Mint && t2 = Mint -> Mint
	| Equal | Neq when t1 = t2 -> Int  (* might want to extend this to allow
        e.g., t1 and t2 both integer types so one can do stone=int *)
	| Less | Leq | Greater | Geq when t1 = Int && t2 = Int -> Int
        | _ -> raise (Failure ("illegal binary operator " ^
              string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
              string_of_typ t2 ^ " in " ^ string_of_expr e))
        )
      | Unop(op, e) as ex -> let t = expr e in
	 (match op with
	   Neg when t = Int -> Int
         | Neg when t = Stone -> Stone
         | Neg when t = Mint -> Mint
         | Neg when t = Point -> Point
         | Neg when t = Char -> Char
         | Not when t = Int -> Int  
         | Deref -> type_of_pointer t e
         | AddrOf -> Pointer(t)
         | Access when t = Mint || t = Point || t = Curve -> Pointer(Stone)
         | _ -> raise (Failure ("illegal unary operator " ^ string_of_uop op ^
	  		   string_of_typ t ^ " in " ^ string_of_expr ex)))
      | Construct2(e1, e2) -> let t1 = expr e1 and t2 = expr e2 in
        (match (t1, t2) with
          (Stone, Stone) -> Mint
        | (Mint, Mint)   -> Curve
        | _ -> raise (Failure ("illegal constructor type pair (" ^ string_of_typ t1 
        ^ "," ^ string_of_typ t2 ^ ")")))
      | Construct3(e1, e2, e3) -> let t1 = expr e1 and t2 = expr e2 and t3 =
          expr e3 in
        (match (t1, t2, t3) with
        | (Curve, Mint, Mint) -> Point
        | _ -> raise (Failure ("illegal constructor type pair (" ^ string_of_typ t1 
        ^ "," ^ string_of_typ t2 ^ "," ^ string_of_typ t3 ^ ")")))
      | Noexpr -> Void

      (* Definitely need to change this to support things which return lvalues,
       * e.g. dereferencing *)
      | Assign(var, e) as ex -> let lt = type_of_identifier var
                                and rt = expr e in
        check_assign lt rt (Failure ("illegal assignment " ^ string_of_typ lt ^
				     " = " ^ string_of_typ rt ^ " in " ^ 
				     string_of_expr ex))
      | ModAssign(var, e) as ex -> let lt = type_of_identifier var
                                   and rt = expr e in
        (match (lt, rt) with
          ((Int|Stone) as t, (Int|Stone)) -> t
        | _ -> raise (Failure ("illegal use of %= with types " ^ string_of_typ
        lt ^ " and " ^ string_of_typ rt ^ " in " ^ string_of_expr ex)))
      | Call(fname, actuals) as call -> let fd = function_decl fname in
         if List.length actuals != List.length fd.formals then
           if fname = "printf" then () else (*variadic fix*)
           raise (Failure ("expecting " ^ string_of_int
             (List.length fd.formals) ^ " arguments in " ^ string_of_expr call))
         else
           List.iter2 (fun (ft, _) e -> let et = expr e in
              ignore (check_assign ft et
                (Failure ("illegal actual argument found " ^ string_of_typ et ^
                " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e))))
             fd.formals actuals;
           fd.typ
    in

    let check_int_expr e = if expr e != Int
     then raise (Failure ("expected integer expression in " ^ string_of_expr e))
     else () in

    (* Verify a statement or throw an exception *)
    let rec stmt in_loop = function
	Block (vl, sl) -> let rec check_block = function
           [Return _ as s] -> stmt in_loop s
         | Return _ :: _ -> raise (Failure "nothing may follow a return")
         | Block (vl, sl) :: ss -> stmt in_loop (Block(vl, sl)); check_block ss;
         | s :: ss -> stmt in_loop s ; check_block ss
         | [] -> ()
        in 
          List.iter (check_not_void (fun n -> "illegal void local " ^ n ^
            " in " ^ func.fname)) vl;

          report_duplicate (fun n -> "duplicate local " ^ n ^ " in " ^ func.fname)
            ((List.map snd vl) @ (List.map fst (StringMap.bindings symbols)));
          
          ignore(symbols = List.fold_left (fun m (t, n) -> StringMap.add n t m)
            symbols (globals @ func.formals @ func.locals ));

          check_block sl
      | Expr e -> ignore (expr e)
      | Return e -> let t = expr e in if t = func.typ then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.typ ^ " in " ^ string_of_expr e))
           
      | If(p, b1, b2) -> check_int_expr p; stmt false b1; stmt false b2 
      | For(e1, e2, e3, st) -> ignore (expr e1); check_int_expr e2;
                               ignore (expr e3); stmt true st
      | While(p, s) -> check_int_expr p; stmt true s
      | DoWhile(s, p) -> stmt true s; check_int_expr p
      | Break -> if in_loop then () else
          raise (Failure ("break statement found outside of a loop context"))
      | Continue -> if in_loop then () else
          raise (Failure ("continue statement found outside of a loop context"))
      | NullStmt -> ()
    in

    stmt false (Block ([], func.body))
   
  in
  List.iter check_function functions
