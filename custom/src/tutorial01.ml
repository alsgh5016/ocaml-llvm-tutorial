open Llvm

let print_instructions_in_blocks b = 
  Llvm.iter_instrs (fun i ->
    Printf.printf "      %s\n" (Llvm.string_of_llvalue i)
    ) b

(* let print_cfg_of_function f = 
  Printf.printf "CFG for function %s:\n" (value_name f);
  Llvm.iter_blocks (fun b ->
    match Llvm.block_terminator b with
    | Some terminator ->
      let successors = Llvm.successors terminator in
      Printf.printf "  Block %s has successors: " (Llvm.value_name (Llvm.value_of_block b));
      Array.iter (fun succ ->
        Printf.printf "    %s " (Llvm.value_name (Llvm.value_of_block succ));
        print_endline "\n      Successor instructions:";
        Llvm.iter_instrs (fun i ->
          Printf.printf "        %s\n" (Llvm.string_of_llvalue i)) succ
          ) successors;
      print_endline ""
    | None -> Printf.printf "  Block %s has no terminator\n" (Llvm.value_name (Llvm.value_of_block b))
    ) f *)

let print_cfg_of_function f =
  Printf.printf "CFG for function %s:\n" (value_name f);
  Llvm.iter_blocks (fun b ->
    let b_name = match Llvm.value_name (Llvm.value_of_block b) with
      | "" -> "Unnamed Block"
      | name -> name in
    match Llvm.block_terminator b with
    | Some terminator ->
      let successors = Llvm.successors terminator in
      if Array.length successors > 0 then (
        Printf.printf "  %s -> (" b_name;
        Array.iter (fun succ ->
          let succ_name = match Llvm.value_name (Llvm.value_of_block succ) with
            | "" -> "Unnamed Succ"
            | name -> name in
          Printf.printf "  %s;" succ_name
          ) successors;
          Printf.printf " }\n";
          Array.iter (fun succ ->
            Printf.printf "    Successor %s instructions:\n" (match Llvm.value_name (Llvm.value_of_block succ) with
            | "" -> "Unnamed Block"
            | name -> name);
            print_instructions_in_blocks succ
            ) successors;
      ) else (
        Printf.printf "    %s has no successors\n" b_name;
      )
    | None -> Printf.printf "    %s has no terminator\n" b_name 
    ) f;
    print_endline ""


let print_instructions m =
  iter_functions (fun f ->
    Printf.printf "Function %s:\n" (value_name f);
    iter_blocks (fun b ->
      iter_instrs (fun i ->
        Printf.printf "   %s\n" (string_of_llvalue i)
        ) b
      ) f
    ) m

let _ =
  (* let llctx = Llvm.global_context () in
  let llmem = Llvm.MemoryBuffer.of_file Sys.argv.(1) in
  let llm = Llvm_bitreader.parse_bitcode llctx llmem in *)
  (* Llvm.dump_module llm ; *)
  (* print_instructions llm; *)
  let context = global_context() in
  let llmem = MemoryBuffer.of_file Sys.argv.(1) in
  let llmodule = Llvm_bitreader.parse_bitcode context llmem in
  iter_functions (fun f -> print_cfg_of_function f) llmodule;
  ()
