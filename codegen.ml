(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast

module StringMap = Map.Make(String)

let translate (globals, functions) =
  let context = L.global_context () in
  let the_module = L.create_module context "Cmod"
  and i64_t  = L.i64_type context (* 8 bytes *)
  and i32_t  = L.i32_type  context
  and i8_t   = L.i8_type   context
  and i1_t   = L.i1_type   context
  and void_t = L.void_type context in
  let obj_pointer = L.pointer_type (L.i64_type context) in  (* void pointer, 8 bytes *)
  let mint_type = L.struct_type context  [| obj_pointer ; obj_pointer |] in (* struct of two void pointers *)
  let curve_type = L.struct_type context [| mint_type ; mint_type |] in (* cruve defined by two modints *)
  let point_type = L.struct_type context [| curve_type ; obj_pointer ; obj_pointer; i1_t |] in(* curve + two stones *)
  (* Must consider best way to implement points wrt Inf *)
  (* maybe define diff points for inf and normal to enforce that 
  it has to be one or two, not arb length array *)

  let rec ltype_of_typ = function
      A.Int -> i32_t
    | A.Char -> i8_t (* chars are 1 byte ints *)
    | A.Void -> void_t 
    | A.Stone -> obj_pointer (* Pointer to arb prec list for C lib *)
    | A.Mint -> mint_type
    | A.Curve -> curve_type 
    | A.Point -> point_type 
    | A.Pointer x -> L.pointer_type (ltype_of_typ x)  in
    (* Cant define pointer w normal form bc need type at time *)

  (* Declare each global variable; remember its value in a map *)
  let global_vars =
    let global_var m (t, n) =
      let init = L.const_int (ltype_of_typ t) 0
      in StringMap.add n ((L.define_global n init the_module), t) m in
    List.fold_left global_var StringMap.empty globals in

  (* Declare printf(), which the print built-in function will call *)
  let printf_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func = L.declare_function "printf" printf_t the_module in

  (* Declare other linked to / "built in" functions *)
  (* Function returns an 8 byte pointer, taking in two 8 byte pointers as arguments *)
  let mint_add_func_t = L.function_type mint_type [| L.pointer_type i8_t ; L.pointer_type i8_t  ; L.pointer_type i8_t  ; L.pointer_type i8_t  |] in 
  
  (*let mint_add_func_t = L.function_type mint_type [| i64_t ; i64_t ; i64_t ; i64_t |] in *)
  let mint_add_func = L.declare_function "mint_add_func" mint_add_func_t the_module in 

  let stone_add_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_add_func = L.declare_function "stone_add_func" stone_add_func_t the_module in 

  let point_add_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let point_add_func = L.declare_function "point_add_func" point_add_func_t the_module in 

  (* Define each function (arguments and return type) so we can call it *)
  let function_decls =
    let function_decl m fdecl =
      let name = fdecl.A.fname
      and formal_types =
	Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.A.formals)
      in let ftype = L.function_type (ltype_of_typ fdecl.A.typ) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in
  
  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.A.fname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p = L.set_value_name n p;
	let local = L.build_alloca (ltype_of_typ t) n builder in
	ignore (L.build_store p local builder);
	StringMap.add n (local, t) m in (* local, t to add type info to map as well *)

      let add_local m (t, n) =
	let local_var = L.build_alloca (ltype_of_typ t) n builder
	in StringMap.add n (local_var, t) m in (* BSURE this might be it *)

      let formals = List.fold_left2 add_formal StringMap.empty fdecl.A.formals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals fdecl.A.locals in

    (* Return the value for a variable or formal argument *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

    (* Construct code for an expression; return its value *)
    let rec expr builder = function
	     A.Literal i -> (L.const_int i32_t i, A.Int) (*we dont want too big of int in here, maybe declare stone literals as strings*)
      | A.String s -> (L.build_global_stringptr s "fmts" builder, A.Pointer(A.Char)) 
      | A.Noexpr -> (L.const_int i32_t 0, A.Void)
      | A.Id s ->
        let binding = lookup s in
          (L.build_load (fst binding) s builder, snd binding)
   (* | A.Construct2 (e1, e2) -> L.set struct body
      | A.Construct3 (e1, e2, e3) -> *)
      | A.Binop (e1, op, e2) ->
    	  let (e1', t1) = expr builder e1
    	  and (e2', t2) = expr builder e2 in (* must t1 == t2 for all binop? if so, t2 can be _ *)
        (match t1 with
           A.Int -> 
              ((match op with
                A.Add     -> L.build_add
              | A.Sub     -> L.build_sub
              | A.Mult    -> L.build_mul
              | A.Div     -> L.build_sdiv
              | A.And     -> L.build_and
              | A.Or      -> L.build_or
              | A.Equal   -> L.build_icmp L.Icmp.Eq
              | A.Neq     -> L.build_icmp L.Icmp.Ne
              | A.Less    -> L.build_icmp L.Icmp.Slt
              | A.Leq     -> L.build_icmp L.Icmp.Sle
              | A.Greater -> L.build_icmp L.Icmp.Sgt
              | A.Geq     -> L.build_icmp L.Icmp.Sge
              ) e1' e2' "tmp" builder, A.Int) 
          | A.Mint ->
              ((match op with
              A.Add -> 
                (*let a1 = L.build_load (L.build_struct_gep e1' 0 "a1p" builder) "a1" builder and
                a2 = L.build_load (L.build_struct_gep e1' 1 "a2p" builder) "a2" builder and
                b1 = L.build_load (L.build_struct_gep e2' 0 "b1p" builder) "b1" builder and
                b2 = L.build_load (L.build_struct_gep e2' 1 "b2p" builder) "b2" builder in
                L.build_call mint_add_func [| a1; a2; b1; b2 |] "mint_add_func" builder *)
              (*wants 4 things that are each point to 64 bits *)
              let a1p = L.build_struct_gep e1' 0 "a1p" builder and
                a2p = L.build_struct_gep e1' 1 "a2p" builder and
                b1p = L.build_struct_gep e2' 0 "b1p" builder and
                b2p = L.build_struct_gep e2' 1 "b2p" builder in

                let a1x = L.build_load a1p "a1x" builder and 
                a2x = L.build_load a2p "a2x" builder and
                b1x = L.build_load b1p "b1x" builder and 
                b2x = L.build_load b2p "b2x" builder in

                (*let a1 = L.build_inttoptr a1x obj_pointer "a1" builder and
                a2 = L.build_inttoptr a2x obj_pointer "a2" builder and 
                b1 = L.build_inttoptr b1x obj_pointer "b1" builder and 
                b2 = L.build_inttoptr b2x obj_pointer "b2" builder in *)

                
                L.build_call mint_add_func [| a1x; a1x; a1x; a1x |] "mint_add_func" builder
              ), A.Mint)
              
          | A.Stone -> 
              ((match op with
              A.Add -> 
                L.build_call stone_add_func [| e1' ; e2' |] "stone_add_func" builder
                
              ), A.Stone) 
          | A.Point ->
              ((match op with
              A.Add -> 
                L.build_call point_add_func [| e1' ; e2' |] "point_add_func" builder

              ), A.Point) 
        )  

      | A.Unop(op, e) -> (*these will also require type matching *)
      	  let e', t = expr builder e in
      	  (match op with
      	     A.Neg     -> L.build_neg
            | A.Not     -> L.build_not) e' "tmp" builder, t

      | A.Assign (s, e) -> let (e', t) = expr builder e in
                       ignore (L.build_store e' (fst (lookup s)) builder); (e', t)
                       
      | A.Call ("print", [e]) | A.Call ("printb", [e]) ->
	       (L.build_call printf_func [| int_format_str ; fst (expr builder e) |]  "printf" builder, A.Void)
      
      | A.Call ("printf", act) ->
          let actuals, types = List.split (List.rev (List.map (expr builder)
          (List.rev act))) in
          let result = "" in  (* printf is void function *)
          (L.build_call printf_func (Array.of_list actuals) result builder, 
            A.Pointer(Char))
      | A.Call (f, act) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
	 let actuals, types = List.split (List.rev (List.map (expr builder) (List.rev act))) in
	 let result = (match fdecl.A.typ with A.Void -> ""
                                            | _ -> f ^ "_result") in
         (L.build_call fdef (Array.of_list actuals) result builder, fdecl.A.typ)

    in

    (* Invoke "f builder" if the current block doesn't already
       have a terminal (e.g., a branch). *)
    let add_terminal builder f =
      match L.block_terminator (L.insertion_block builder) with
	Some _ -> ()
      | None -> ignore (f builder) in
	
    (* Build the code for the given statement; return the builder for
       the statement's successor *)
    let rec stmt builder = function
	     A.Block sl -> List.fold_left stmt builder sl
      | A.Expr e -> ignore (expr builder e); builder
      | A.Return e -> ignore (match fdecl.A.typ with
	                 A.Void -> L.build_ret_void builder
	    | _ -> L.build_ret (fst (expr builder e)) builder); builder
      | A.If (predicate, then_stmt, else_stmt) ->
         let bool_val = fst(expr builder predicate) in
	 let merge_bb = L.append_block context "merge" the_function in

	 let then_bb = L.append_block context "then" the_function in
	 add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
	   (L.build_br merge_bb);

	 let else_bb = L.append_block context "else" the_function in
	 add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
	   (L.build_br merge_bb);

	 ignore (L.build_cond_br bool_val then_bb else_bb builder);
	 L.builder_at_end context merge_bb

      | A.While (predicate, body) ->
	  let pred_bb = L.append_block context "while" the_function in
	  ignore (L.build_br pred_bb builder);

	  let body_bb = L.append_block context "while_body" the_function in
	  add_terminal (stmt (L.builder_at_end context body_bb) body)
	    (L.build_br pred_bb);

	  let pred_builder = L.builder_at_end context pred_bb in
	  let bool_val = fst (expr pred_builder predicate) in

	  let merge_bb = L.append_block context "merge" the_function in
	  ignore (L.build_cond_br bool_val body_bb merge_bb pred_builder);
	  L.builder_at_end context merge_bb

      | A.For (e1, e2, e3, body) -> stmt builder
	    ( A.Block [A.Expr e1 ; A.While (e2, A.Block [body ; A.Expr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (A.Block fdecl.A.body) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.A.typ with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module
