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
  (*and i64_t  = L.i64_type context *)
  and i32_t  = L.i32_type  context
  and i8_t   = L.i8_type   context
  and void_t = L.void_type context in
  let obj_pointer = L.pointer_type (L.i8_type context) in  (* void pointer, 8 bytes *)
  let mint_type = L.struct_type context  [| obj_pointer ; obj_pointer |] in (* struct of two void pointers *)
  let curve_type = L.struct_type context [| mint_type ; mint_type |] in (* cruve defined by two modints *)
  let point_type = L.struct_type context [| curve_type ; obj_pointer ;
  obj_pointer; i8_t |] in(* curve + two stones *)
  let point_ptr = L.pointer_type point_type in
  let curve_ptr = L.pointer_type curve_type in
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
      in StringMap.add n ((L.define_global n init the_module), (t, 0)) m in
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
  
  let div_print_func_t = L.function_type i32_t [| mint_type |] in 
  let div_print_func = L.declare_function "div_print_func" div_print_func_t the_module in
  
  let point_print_func_t = L.function_type i32_t [| point_ptr |] in 
  let point_print_func = L.declare_function "point_print_func" point_print_func_t the_module in

  let point_print_sep_func_t = L.function_type i32_t [| point_ptr |] in 
  let point_print_sep_func = L.declare_function "point_print_sep_func"
  point_print_sep_func_t the_module in
  
  let curve_print_func_t = L.function_type i32_t [| curve_ptr |] in 
  let curve_print_func = L.declare_function "curve_print_func" curve_print_func_t the_module in

  let point_add_func_t = L.function_type point_ptr [| point_ptr ; point_ptr |] in 
  let point_add_func = L.declare_function "point_add_func" point_add_func_t the_module in 

  let point_sub_func_t = L.function_type point_ptr [| point_ptr ; point_ptr |] in 
  let point_sub_func = L.declare_function "point_sub_func" point_sub_func_t the_module in 
 
  let atoi_func_t = L.function_type i32_t [| L.pointer_type i8_t |] in
  let atoi_func = L.declare_function "atoi" atoi_func_t the_module in

  (* stone * point, i.e. add point to itself stone many times *)
  let point_mult_func_t = L.function_type point_ptr [| obj_pointer ; point_ptr |] in 
  let point_mult_func = L.declare_function "point_mult_func" point_mult_func_t
  the_module in 

  let stone_create_func_t = L.function_type obj_pointer [| L.pointer_type i8_t |] in 
  let stone_create_func = L.declare_function "stone_create_func" stone_create_func_t the_module in 

  let curve_create_func_t = L.function_type curve_ptr [| mint_type ; mint_type |] in 
  let curve_create_func = L.declare_function "curve_create_func" curve_create_func_t the_module in 
  
  let point_create_func_t = L.function_type point_ptr 
    [| curve_ptr ; obj_pointer ; obj_pointer |] in
  let point_create_func = L.declare_function "point_create_func" 
    point_create_func_t the_module in 
  
  let stone_free_t = L.function_type i32_t [| L.pointer_type i8_t |] in (* bn free func *)
  let stone_free_func = L.declare_function "stone_free_func" stone_free_t the_module in 

 (* let mint_free_t = L.function_type i32_t [| mint_pointer |] in 
  let mint_free_func = L.declare_function "mint_free_func" mint_free_t the_module in *)

  let access_mint_t = L.function_type obj_pointer [| mint_type ; i32_t |] in
    let access_mint = L.declare_function "access_mint" access_mint_t the_module in

  let access_curve_t = L.function_type obj_pointer [| curve_ptr ; i32_t |] in
    let access_curve = L.declare_function "access_curve" access_curve_t the_module in

  let access_point_t = L.function_type obj_pointer [| point_ptr ; i32_t |] in
    let access_point = L.declare_function "access_point" access_point_t the_module in

  let invert_point_func_t = L.function_type point_type [| point_type |] in
    let invert_point_func = L.declare_function "invert_point_func" invert_point_func_t the_module in


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

    let char_format_str = L.build_global_stringptr "%s" "fmt2" builder in 

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)

    (* Return the value for a variable or formal argument *)
    let lookup n table = try StringMap.find n table
                   with Not_found -> StringMap.find n global_vars
    in

    let manage l1 l2 ex ex2 = 
          let _ = if (l1 = 0) then 
              ignore(L.build_call stone_free_func [| ex |] "res" builder)
          else () in
          if (l2 = 0) then
               ignore(L.build_call stone_free_func [| ex2 |] "res" builder)
          else ()  
    in 

    (*let manage_mint l1 l2 ex ex2 = 
          let _ = if (l1 = 0) then 
              ignore(L.build_call mint_free_func [| ex |] "res" builder)
          else () in
          if (l2 = 0) then
               ignore(L.build_call mint_free_func [| ex2 |] "res" builder)
          else ()  
    in     *)

    (* Construct code for an expression; return its value *)
    let rec expr table builder = function
	     A.Literal i -> (L.const_int i32_t i, (A.Int, 0))
        (*we dont want too big of int in here, maybe declare stone literals as strings*)
      | A.String s -> (L.build_global_stringptr s "fmts" builder, (A.Pointer(A.Char), 0)) 
      | A.Noexpr -> (L.const_int i32_t 0, (A.Void, 0))
      | A.Id s ->
        let binding = lookup s table in
          (L.build_load (fst binding) s builder, (fst (snd binding), 1))
      | A.Construct2 (e1, e2) -> 
        let (e1', (t1, _)) = expr table builder e1
        and (e2', (t2, _)) = expr table builder e2 in 
        (match (t1, t2) with
          (A.Stone, A.Stone) ->
            let struct_m = L.undef mint_type in 
              let reduced_val = L.build_call stone_mod_func [| e1' ; e2' |] 
                 "stone_mod_res" builder in
                let struct_m2 = L.build_insertvalue struct_m (reduced_val) 0 "sm" builder in
            (L.build_insertvalue struct_m2 e2' 1 "sm2" builder, (A.Mint, 1)) (*1 right?*) 
          | (A.Mint, A.Mint) -> 
            (L.build_call curve_create_func [| e1' ; e2' |] "curve_create_res"
            builder, (A.Pointer(A.Curve), 1))
          | _ ->  raise(Failure("wrong types in construct2")))  
          (* impossible; semant will check this *)

      | A.Construct3 (e1, e2, e3) ->
        let (e1', (t1, _)) = expr table builder e1
        and (e2', (t2, _)) = expr table builder e2
        and (e3', (t3, _)) = expr table builder e3 in 
        (match (t1, t2, t3) with
          (A.Pointer(A.Curve), A.Stone, A.Stone) -> (*only construct 3?*)
              (L.build_call point_create_func [| e1' ; e2' ; e3' |] 
                 "point_create_res" builder, (A.Pointer(A.Point), 1))
          | _ ->  raise(Failure("wrong types in construct3")))  
          (* this last match is impossible; semant will check this 
           * correct solution is to make a "polymorphic variant"; no one has 
           * time for that *)
      | A.Binop (e1, op, e2) ->
    	  let (e1', (t1, leaf1)) = expr table builder e1
    	  and (e2', (t2, leaf2)) = expr table builder e2 in
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
              | _ as o -> raise(Failure("Illegal operator " ^  A.string_of_op o
              ^ " in int * int binop"))
              ) e1' e2' "tmp" builder, (A.Int, 0))
          | (A.Mint, A.Mint) ->
              let ptr1 = L.build_alloca mint_type "e1" builder and
              ptr2 = L.build_alloca mint_type "e2" builder in 
              let _ = L.build_store e1' ptr1 builder and 
              _ = L.build_store e2' ptr2 builder in 
              ((match op with
                  A.Add -> 
                    L.build_call mint_add_func [| ptr1 ; ptr2 |] "mint_add_res" builder (*?? can i just this?*)
                | A.Sub ->  
                    L.build_call mint_sub_func [| ptr1 ; ptr2 |] "mint_sub_res" builder
                | A.Mult ->  
                    L.build_call mint_mult_func [| ptr1 ; ptr2 |] "mint_mult_res" builder
                | A.Pow ->  
                    L.build_call mint_pow_func [| ptr1 ; ptr2 |] "mint_pow_res" builder
                | _ as o -> raise(Failure("Illegal operator " ^  A.string_of_op o
                 ^ " in mint * mint binop"))
              ), (A.Mint, 0))

            (*Raise mint to stone*)
          | (A.Mint, A.Stone) ->
              ((match op with
                (* In semant, check that this is only op possible *)
              A.Pow -> 
                  let ptr = L.build_alloca mint_type "e1" builder in
                  let _ = L.build_store e1' ptr builder in 

                  L.build_call mint_to_stone_func [| ptr ; e2' |]
                  "mint_to_stone_res" builder
           | _ as o -> raise(Failure("Illegal operator " ^  A.string_of_op o
              ^ " in mint * stone binop"))

              ), (A.Mint, 0))
              
          | (A.Stone, A.Stone) -> 
              ((match op with
                A.Add -> 
                let call = L.build_call stone_add_func [| e1' ; e2' |] "stone_add_res" builder in    
                 let _ = manage leaf1 leaf2 e1' e2' in 
                call
                (*L.build_call stone_add_func [| e1' ; e2' |] "stone_add_res" builder*)
              | A.Sub -> 
                let call = L.build_call stone_sub_func [| e1' ; e2' |] "stone_sub_res" builder in 
                  let _ = manage leaf1 leaf2 e1' e2' in 
                call
              | A.Mult -> 
                let call = L.build_call stone_mult_func [| e1' ; e2' |] "stone_mult_res" builder in 
                  let _ = manage leaf1 leaf2 e1' e2' in 
                call
              | A.Div -> 
                let call = L.build_call stone_div_func [| e1' ; e2' |] "stone_div_res" builder in
                  let _ = manage leaf1 leaf2 e1' e2' in 
                call
              | A.Pow -> 
                let call = L.build_call stone_pow_func [| e1' ; e2' |] "stone_pow_res" builder in 
                  let _ = manage leaf1 leaf2 e1' e2' in 
                call
              | A.Mod -> 
                let call = L.build_call stone_mod_func [| e1' ; e2' |] "stone_mod_res" builder in 
                  let _ = manage leaf1 leaf2 e1' e2' in 
                call
              | _ as o -> raise(Failure("Illegal operator " ^  A.string_of_op o
              ^ " in stone * stone binop"))
              ), (A.Stone, 0)) 
          | (A.Pointer(A.Point), A.Pointer(A.Point)) ->
              ((match op with
              A.Add -> 
                L.build_call point_add_func [| e1' ; e2' |] "point_add_res" builder
            | A.Sub -> 
                L.build_call point_sub_func [| e1' ; e2' |] "point_sub_res" builder
            | _ as o -> raise(Failure("Illegal operator " ^  A.string_of_op o
              ^ " in point* * point* binop"))
              ), (A.Pointer(A.Point), 0))
         | (A.Stone, A.Pointer(A.Point)) ->
              ((match op with
              A.Mult ->
                  L.build_call point_mult_func [| e1' ; e2' |] "point_mult_res"
                  builder
              | _ as o -> raise(Failure("Illegal operator " ^  A.string_of_op o
              ^ " in stone * point binop"))
              ), (A.Pointer(A.Point), 0))
         | _ ->
                raise(Failure("illegal binop type " ^ A.string_of_typ t1 ^
                A.string_of_op op ^ A.string_of_typ t2))
        )  


      | A.Unop(op, e) -> 
      	  let e', (t, _) = expr table builder e in
      	  ((match op with
            A.Neg     -> (match t with
                A.Int -> L.build_neg e' "tmp" builder
               (* | A.Point -> L.build_call invert_point_func [| e' |] "invert_point_func" builder *) )  (* Point inversion *)
           | A.Not     -> L.build_icmp L.Icmp.Eq (L.const_null (ltype_of_typ t)) e' "tmp" builder  (* Still need to test on Pointer types *)
           | _ -> raise(Failure("not implemented yet")) e' "tmp" builder
        (* | A.Deref   -> L.build_load e' "tmp" builder  *) (* load object pointed to *)
        (* | A.AddrOf  -> fst(lookup e')  *)(*L.build_store e'  builder*)
          ), (match op with
            A.Neg -> (t, 0)
            | A.Not -> (t, 0)
            | _ -> (t, 0)
            (* | A.Deref -> (match t with
                A.Pointer x -> x)
            | A.AddrOf -> A.Pointer t *)))   
       | A.Assign (s, e) -> let (e', (t, _)) = expr table builder e and
                              (* if t string, otherwise is behavior normal?*)
                            (*snd lookup is type of thing*)
                           ltype = (fst (snd (lookup s table))) in (match (ltype, t) with
                           | (A.Stone, A.Pointer(A.Char)) -> 
                              let ptr = 
                                L.build_call stone_create_func [|e' |] "stone_create_func" builder in 
                                 (*let res = 
                                  L.build_call stone_char_func [| e' ; ptr |]
                                  "stone_char_func" builder in *)
                                  ignore(L.build_store ptr (fst (lookup s table)) builder); (ptr, (t, 0))


                           | _ -> ignore (L.build_store e' (fst (lookup s table)) builder); (e', (t, 0)) )
                       


      | A.Call("access_mint", [e; i]) -> let (e', (t, _)) = expr table builder e and (i', (t', _)) = expr table builder i in 
          (L.build_call access_mint [| e' ; i' |] "access_mint" builder, (A.Stone, 0));
      | A.Call("access_curve", [e; i]) -> let (e', (t, _)) = expr table builder e and (i', (t', _)) = expr table builder i in 
          (L.build_call access_curve [| e' ; i' |] "access_curve" builder, (A.Stone, 0));
      | A.Call("access_point", [e; i]) -> let (e', (t, _)) = expr table builder e and (i', (t', _)) = expr table builder i in 
          (L.build_call access_point [| e' ; i' |] "access_point" builder, (A.Stone, 0));
      | A.Call ("printf", act) ->
          let actuals, _ = List.split (List.rev (List.map (expr table builder)
          (List.rev act))) in
          let result = "" in  (* printf is void function *)
          (L.build_call printf_func (Array.of_list actuals) result builder, 
            (A.Pointer(A.Char), 0))
      | A.Call("print_point", [e]) -> let (e', (t, _)) = expr table builder e in 
          (L.build_call point_print_func [| e' |] "point_print_res" builder, (t, 0));
      | A.Call("print_point_sep", [e]) -> let (e', (t, _)) = expr table builder e in 
          (L.build_call point_print_sep_func [| e' |] "point_print_res" builder, (t, 0));
      | A.Call("print_curve", [e]) -> let (e', (t, _)) = expr table builder e in 
          (L.build_call curve_print_func [| e' |] "curve_print_res" builder, (t, 0));
      | A.Call("print_stone", [e]) -> let (e', (t, _)) = expr table builder e in 
          (L.build_call stone_print_func [| e' |] "stone_print_func" builder, (t, 0)); 
      | A.Call("print_mint", [e]) -> let (e', (t, _)) = expr table builder e in 
          (L.build_call mint_print_func [| e' |] "mint_print_func" builder, (t, 0));
      | A.Call("print_div", [e]) -> let (e', (t, _)) = expr table builder e in 
          (L.build_call div_print_func [| e' |] "div_print_func" builder, (t, 0));
      | A.Call("scanf", [e]) -> 
          let (e', (t, _)) = expr table builder e in 
            ignore(L.build_call read_func [| char_format_str ; e' |] "scanf" builder ); 
            (e' , (t, 0)) 
      | A.Call("malloc", [e]) -> 
          let (e', (t, _)) = expr table builder e in
          (L.build_call malloc_func [| e' |] "malloc" builder, (t, 0))
      | A.Call("free", [e]) -> 
          let (e', (t, _)) = expr table builder e in
          (L.build_free e' builder, (A.Void, 0)) (*void correct?*)
      | A.Call("atoi", [e]) ->
          let (e', (t, _)) = expr table builder e in
          (L.build_call atoi_func [| e' |] "atoi_res" builder, (t, 0));
      | A.Call (f, act) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
	         let actuals, _ = List.split (List.rev (List.map (expr table builder) (List.rev act))) in
	         let result = (match fdecl.A.typ with A.Void -> ""
                                            | _ -> f ^ "_result") in
          (L.build_call fdef (Array.of_list actuals) result builder, (fdecl.A.typ, 0))
      | _ -> raise(Failure("illegal expression"))

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
           in StringMap.add n (local_var, (t, 0)) m 
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
      | _ -> raise(Failure("illegal statement"))

    in

    let local_vars =
      let add_formal m (t, n) p = L.set_value_name n p;
      	let local = L.build_alloca (ltype_of_typ t) n builder in
      	ignore (L.build_store p local builder);
      	StringMap.add n (local, (t, 0)) m in (* local, t to add type info to map as well *)

      let add_local m (t, n) =
      	let local_var = L.build_alloca (ltype_of_typ t) n builder
      	in StringMap.add n (local_var, (t, 0)) m in (* BSURE this might be it *)

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
