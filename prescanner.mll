
  (* Ocamllex scanner for MicroC *)
{   open Parser
    module B = Buffer }

(* why are some string and some chars LT, GT eg *)

rule prepro m = parse
  '#'        { handle_pound m lexbuf }
| _ as t     { print_char t; prepro m lexbuf }

and

handle_pound m = parse
  "include"  { handle_file m lexbuf }
| "define"   { handle_define m lexbuf }
| "ifdef"    { handle_ifdef m lexbuf }
| "endif"    { raise(Failure("unexpected #endif")) }
| _ as t     { raise(Failure("unexpected word " ^ t ^ " found after #")) }

and

handle_file m = parse
  "\""(_ as file)"\""     { let in_stream = open_in file in prepro m in_stream }

and 

handle_define m = parse
  (_ as k)" "(_ as v)  { StringMap.add k v m }

and

handle_ifdef m = parse
" "(_ as t)" "       { try StringMap.find t m w; find_endif lexbuf with
                       Not_found -> prepro m lexbuf } 
