open Llvm

let print_instructions_in_blocks b = 
  Llvm.iter_instrs (fun i ->
    Printf.printf "      %s\n" (Llvm.string_of_llvalue i)
    ) b

let print_cfg_of_function f =
  Printf.printf "CFG for function %s:\n" (Llvm.value_name f);
  (* 함수 내의 기본 블록들을 순회하며 번호 매기기 *)
  let blocks = Llvm.fold_left_blocks (fun (acc, idx) b -> ((b, idx) :: acc, idx + 1)) ([], 0) f in
  let blocks = List.rev (fst blocks) in  (* 순서대로 번호를 매기기 위해 리스트를 뒤집습니다. *)
  Llvm.iter_blocks (fun b ->
    let b_index = List.assoc b blocks in
    let b_name = Printf.sprintf "block %d:" b_index in
    Printf.printf "%s\n" b_name;
    (* 여기에 각 블록의 IR 지시어를 출력하는 코드 추가 *)
    Llvm.iter_instrs (fun i ->
      Printf.printf "  %s\n" (Llvm.string_of_llvalue i)
    ) b;
    match Llvm.block_terminator b with
    | Some terminator ->
      let successors = Llvm.successors terminator in
      if Array.length successors > 0 then (
        Printf.printf "  %s has successors {" b_name;
        Array.iter (fun succ ->
          let succ_index = List.assoc succ blocks in
          let succ_name = Printf.sprintf "block %d" succ_index in
          Printf.printf " %s;" succ_name
        ) successors;
        Printf.printf " }\n";
      ) else (
        Printf.printf "  %s has no successors\n" b_name;
      )
    | None -> Printf.printf "  %s has no terminator\n" b_name 
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
