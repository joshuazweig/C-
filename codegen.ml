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
  let obj_pointer = L.pointer_type (L.i8_type context) in  (* void pointer, 8 bytes *)
  let mint_type = L.struct_type context  [| obj_pointer ; obj_pointer |] in (* struct of two void pointers *)
  let curve_type = L.struct_type context [| mint_type ; mint_type |] in (* cruve defined by two modints *)
  let point_type = L.struct_type context [| curve_type ; obj_pointer ;
  obj_pointer; i8_t |] in(* curve + two stones *)
  let mint_pointer = L.pointer_type mint_type in
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
    | A.Pointer x -> L.pointer_type (ltype_of_typ x) in
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

  let read_t = L.function_type i32_t [| L.pointer_type i8_t ; L.pointer_type i8_t |] in 
  let read_func = L.declare_function "scanf" read_t the_module in 

  let malloc_t = L.function_type (L.pointer_type i8_t) [| i32_t |] in
  let malloc_func = L.declare_function "malloc" malloc_t the_module in

  let free_t = L.function_type void_t [| L.pointer_type i8_t |] in
  let free_func = L.declare_function "free" free_t the_module in

  (* Declare other linked to / "built in" functions *)
  (* Function returns an 8 byte pointer, taking in two 8 byte pointers as arguments *)
  let mint_add_func_t = L.function_type mint_type [| mint_pointer ; mint_pointer |] in 
  let mint_add_func = L.declare_function "mint_add_func" mint_add_func_t the_module in 

  let mint_sub_func_t = L.function_type mint_type [| mint_pointer ; mint_pointer |] in 
  let mint_sub_func = L.declare_function "mint_sub_func" mint_sub_func_t the_module in 
  
  let mint_mult_func_t = L.function_type mint_type [| mint_pointer ; mint_pointer |] in 
  let mint_mult_func = L.declare_function "mint_mult_func" mint_mult_func_t the_module in 

  let mint_pow_func_t = L.function_type mint_type [| mint_pointer ; mint_pointer |] in 
  let mint_pow_func = L.declare_function "mint_pow_func" mint_pow_func_t the_module in 

  let mint_to_stone_func_t = L.function_type mint_type [| mint_pointer ; obj_pointer |] in
  let mint_to_stone_func = L.declare_function "mint_to_stone_func" mint_to_stone_func_t the_module in

  let stone_char_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_char_func = L.declare_function "stone_char_func" stone_char_func_t the_module in 

  let stone_add_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_add_func = L.declare_function "stone_add_func" stone_add_func_t the_module in 

  let stone_sub_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_sub_func = L.declare_function "stone_sub_func" stone_sub_func_t the_module in 
  
  let stone_mult_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_mult_func = L.declare_function "stone_mult_func" stone_mult_func_t the_module in

  let stone_div_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_div_func = L.declare_function "stone_div_func" stone_div_func_t the_module in

  let stone_pow_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_pow_func = L.declare_function "stone_pow_func" stone_pow_func_t the_module in

  let stone_mod_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let stone_mod_func = L.declare_function "stone_mod_func" stone_mod_func_t the_module in

  let stone_print_func_t = L.function_type i32_t [| obj_pointer |] in 
  let stone_print_func = L.declare_function "stone_print_func" stone_print_func_t the_module in

  let mint_print_func_t = L.function_type i32_t [| mint_type |] in 
  let mint_print_func = L.declare_function "mint_print_func" mint_print_func_t the_module in
  
  let point_add_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let point_add_func = L.declare_function "point_add_func" point_add_func_t the_module in 

  let point_sub_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let point_sub_func = L.declare_function "point_sub_func" point_sub_func_t the_module in 

  (* stone * point, i.e. add point to itself stone many times *)
  let point_mult_func_t = L.function_type obj_pointer [| obj_pointer ; obj_pointer |] in 
  let point_mult_func = L.declare_function "point_mult_func" point_mult_func_t the_module in 

  let stone_create_func_t = L.function_type obj_pointer [| ltype_of_typ (A.Pointer(Char)) |] in 
  let stone_create_func = L.declare_function "stone_create_func" stone_create_func_t the_module in 

  let bn_free_t = L.function_type i32_t [| L.pointer_type i8_t |] in (* bn free func *)
  let stone_free_func = L.declare_function "stone_free_func" bn_free_t the_module in 

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
    let char_format_str = L.build_global_stringptr "%s" "fmt2" builder in 

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)

    (* Return the value for a variable or formal argument *)
    let lookup n table = try StringMap.find n table
                   with Not_found -> StringMap.find n global_vars
    in

    (* Construct code for an expression; return its value *)
    let rec expr table builder = function
	     A.Literal i -> (L.const_int i32_t i, A.Int) (*we dont want too big of int in here, maybe declare stone literals as strings*)
      | A.String s -> (L.build_global_stringptr s "fmts" builder, A.Pointer(A.Char)) 
      | A.Noexpr -> (L.const_int i32_t 0, A.Void)
      | A.Id s ->
        let binding = lookup s table in
          (L.build_load (fst binding) s builder, snd binding)
    | A.Construct2 (e1, e2) -> 
        let (e1', t1) = expr table builder e1
        and (e2', t2) = expr table builder e2 in 
        (match (t1, t2) with
          (A.Stone, A.Stone) -> 
            let struct_m = L.undef mint_type in 
              let reduced_val = L.build_call stone_mod_func [| e1' ; e2' |] 
                 "stone_mod_res" builder in
                let struct_m2 = L.build_insertvalue struct_m (reduced_val) 0 "sm" builder in
            (L.build_insertvalue struct_m2 e2' 1 "sm2" builder, A.Mint) 
          | (A.Mint, A.Mint) -> 
            let struct_c = L.undef curve_type in 
            let struct_c2 = L.build_insertvalue struct_c e1' 0 "sc" builder in 
            (L.build_insertvalue struct_c2 e2' 1 "sc2" builder, A.Curve))
          
          (* last would have been point type but now controlled by bit in construct3 *)

      | A.Construct3 (e1, e2, e3) ->
        let (e1', t1) = expr table builder e1
        and (e2', t2) = expr table builder e2
        and (e3', t3) = expr table builder e3 in 
        (match (t1, t2, t3) with
          (A.Curve, A.Stone, A.Stone) -> (*only construct 3?*)
            let struct_p = L.undef point_type in
            let struct_p2 = L.build_insertvalue struct_p e1' 0 "sp" builder in 
            let struct_p3 = L.build_insertvalue struct_p2 e2' 1 "sp2" builder in
            let struct_p4 = L.build_insertvalue struct_p3 e3' 2 "sp3" builder in
            (L.build_insertvalue struct_p4 (L.const_int i1_t 0) 3 "sp4" builder, A.Point))
      
      | A.Binop (e1, op, e2) ->
    	  let (e1', t1) = expr table builder e1
    	  and (e2', t2) = expr table builder e2 in
        (match (t1, t2) with
           (A.Int, A.Int) -> 
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
          | (A.Mint, A.Mint) ->
              let ptr1 = L.build_alloca mint_type "e1" builder and
              ptr2 = L.build_alloca mint_type "e2" builder in 
              let s = L.build_store e1' ptr1 builder and 
              s1 = L.build_store e2' ptr2 builder in 
              ((match op with
                  A.Add -> 
                    L.build_call mint_add_func [| e1' ; e2' |] "mint_add_res" builder (*?? can i just this?*)
                | A.Sub ->  
                    L.build_call mint_sub_func [| ptr1 ; ptr2 |] "mint_sub_res" builder
                | A.Mult ->  
                    L.build_call mint_mult_func [| ptr1 ; ptr2 |] "mint_mult_res" builder
                | A.Pow ->  
                    L.build_call mint_pow_func [| ptr1 ; ptr2 |] "mint_pow_res" builder
              ), A.Mint)

            (*Raise mint to stone*)
          | (A.Mint, A.Stone) ->
              ((match op with
                (* In semant, check that this is only op possible *)
              A.Pow -> 
                  let ptr = L.build_alloca mint_type "e1" builder in
                  let s = L.build_store e1' ptr builder in 

                  L.build_call mint_to_stone_func [| ptr ; e2' |]
                  "mint_to_stone_res" builder

              ), A.Mint)
              
          | (A.Stone, A.Stone) -> 
              ((match op with
                A.Add -> 
                let call = L.build_call stone_add_func [| e1' ; e2' |] "stone_add_res" builder in 
                    let _ = ignore(StringMap.iter (fun k v -> 
                          if v != (e1', A.Stone) then ignore(L.build_call 
                            stone_free_func [| e1' |] "res" builder)
                          else if v != (e2', A.Stone) then ignore(L.build_call
                            stone_free_func [| e2' |] "res" builder)
                          else ignore((L.const_int i1_t 0))) table) in
                call
                (*ignore (if StringMap.mem e1' table then (* check if e1' is a value in the map *)
                          L.build_call stone_free_func [| e1' |] "res" builder
                        else if StringMap.mem e2' table then 
                          L.build_call stone_free_func [| e2' |] "res" builder)*)
                

              | A.Sub -> 
                L.build_call stone_sub_func [| e1' ; e2' |] "stone_sub_res" builder
              | A.Mult -> 
                L.build_call stone_mult_func [| e1' ; e2' |] "stone_mult_res" builder
              | A.Div -> 
                L.build_call stone_div_func [| e1' ; e2' |] "stone_div_res" builder
              | A.Pow -> 
                L.build_call stone_pow_func [| e1' ; e2' |] "stone_pow_res" builder
              | A.Mod -> 
                L.build_call stone_mod_func [| e1' ; e2' |] "stone_mod_res" builder
              (*| A.Sub ->
              | A.Equal -> 
              | A.Neq -> 
              | A.Less -> 
              | A.Leq -> 
              | A.Greater ->
              | A.Geq ->
              | A.And ->
              | A.Or -> *)

              ), A.Stone) 
          | (A.Point, A.Point) ->
              ((match op with
              A.Add -> 
                L.build_call point_add_func [| e1' ; e2' |] "point_add_res" builder
            | A.Sub -> 
                L.build_call point_sub_func [| e1' ; e2' |] "point_sub_res" builder
              ), A.Point) 
         | (A.Stone, A.Point) ->
              ((match op with
              A.Mult ->
                  L.build_call point_mult_func [| e1' ; e2' |] "point_mult_res"
                  builder
              ), A.Point)
        )  

      | A.Unop(op, e) -> (*these will also require type matching *)
      	  let e', t = expr table builder e in
      	  (match op with
      	     A.Neg     -> L.build_neg
            | A.Not     -> L.build_not) e' "tmp" builder, t

       | A.Assign (s, e) -> let (e', t) = expr table builder e and
                              (* if t string, otherwise is behavior normal?*)
                            (*snd lookup is type of thing*)
                           ltype = (snd (lookup s table)) in (match (ltype, t) with
                           | (A.Stone, A.Pointer(A.Char)) -> 
                              let ptr = 
                                L.build_call stone_create_func [|e' |] "stone_create_func" builder in 
                                 (*let res = 
                                  L.build_call stone_char_func [| e' ; ptr |]
                                  "stone_char_func" builder in *)
                                  ignore(L.build_store ptr (fst (lookup s table)) builder); (ptr, t)

                           | _ -> ignore (L.build_store e' (fst (lookup s table)) builder); (e', t) )
                       

      | A.Call ("printf", act) ->
          let actuals, types = List.split (List.rev (List.map (expr table builder)
          (List.rev act))) in
          let result = "" in  (* printf is void function *)
          (L.build_call printf_func (Array.of_list actuals) result builder, 
            A.Pointer(Char))
      | A.Call("print_stone", [e]) -> let (e', t) = expr table builder e in 
          (L.build_call stone_print_func [| e' |] "stone_print_func" builder, t); 
     | A.Call("print_mint", [e]) -> let (e', t) = expr table builder e in 
          (L.build_call mint_print_func [| e' |] "mint_print_func" builder, t);       
      | A.Call("scanf", [e]) -> 
          let (e', t) = expr table builder e in 
            ignore(L.build_call read_func [| char_format_str ; e' |] "scanf" builder ); 
            (e' , t) 
      | A.Call("malloc", [e]) -> 
          let (e', t) = expr table builder e in
          (L.build_call malloc_func [| e' |] "malloc" builder, t)
      | A.Call("free", [e]) -> 
          let (e', t) = expr table builder e in
          (*ignore(L.build_call free_func [| e' |] "free" builder);
          (e', t) (*is this right to return?*)*)
          (L.build_free e' builder, Void)
      | A.Call (f, act) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
	         let actuals, types = List.split (List.rev (List.map (expr table builder) (List.rev act))) in
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
    let rec stmt table builder = function
	     A.Block (vl, sl) ->  
        let new_table =  
         let add_local m (t, n) =
          let local_var = L.build_alloca (ltype_of_typ t) n builder
           in StringMap.add n (local_var, t) m 
         in
         List.fold_left add_local table vl
       in 
       List.fold_left (stmt new_table) builder sl

      | A.Expr e -> ignore (expr table builder e); builder
      | A.Return e -> ignore (match fdecl.A.typ with
	                 A.Void -> L.build_ret_void builder
	    | _ -> L.build_ret (fst (expr table builder e)) builder); builder
      | A.If (predicate, then_stmt, else_stmt) ->
         let bool_val = fst (expr table builder predicate) in
	 let merge_bb = L.append_block context "merge" the_function in

	 let then_bb = L.append_block context "then" the_function in
	 add_terminal (stmt table (L.builder_at_end context then_bb) then_stmt)
	   (L.build_br merge_bb);

	 let else_bb = L.append_block context "else" the_function in
	 add_terminal (stmt table (L.builder_at_end context else_bb) else_stmt)
	   (L.build_br merge_bb);

	 ignore (L.build_cond_br bool_val then_bb else_bb builder);
	 L.builder_at_end context merge_bb

      | A.While (predicate, body) ->
	  let pred_bb = L.append_block context "while" the_function in
	  ignore (L.build_br pred_bb builder);

	  let body_bb = L.append_block context "while_body" the_function in
	  add_terminal (stmt table (L.builder_at_end context body_bb) body)
	    (L.build_br pred_bb);

	  let pred_builder = L.builder_at_end context pred_bb in
	  let bool_val = fst (expr table pred_builder predicate) in

	  let merge_bb = L.append_block context "merge" the_function in
	  ignore (L.build_cond_br bool_val body_bb merge_bb pred_builder);
	  L.builder_at_end context merge_bb

      | A.For (e1, e2, e3, body) -> stmt table builder
      ( A.Block ([], [A.Expr e1 ; A.While (e2, A.Block ([], [body ; A.Expr e3])) ] ))
    in

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

    (* Build the code for each statement in the function *)
    let builder = stmt local_vars builder (A.Block ([], fdecl.A.body)) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.A.typ with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module
