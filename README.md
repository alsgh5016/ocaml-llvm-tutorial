# ocaml-llvm-tutorial

# Install ocaml package in your Ubuntu System
```
bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
opam init
opam switch create 4.11.1
eval $(opam env --switch=4.11.1)
opam install ocamlbuild ocamlfind
opam install llvm.14.0.6
```
- opam env 버전은 적당히 골라서 사용하면 됨
    - part1, part2, part3, part4 Makefile에서 env 버전 경로만 정확하게 저장하면 됨

    ```
    ...
    OCAML_VERSION := 4.11.1 # write your env version
    LLVM_VERSION := 14 # write your llvm version
    ...
    export OCAMLPATH=$(HOME)/.opam/$(OCAML_VERSION)/lib/
    ...
    run: $(TOOLS) hello.bc
	    CAML_LD_LIBRARY_PATH=$(OCAMLPATH)/stublibs/ ./build/tutorial01/src/tutorial01.byte hello.bc
    ...
    ```

- opam install llvm 혹은 llvm.15.0.6 이상의 버전으로 설치하면, opam과 ocamlfind 사이에 version conflict가 발생함

## Run Makefile in part1 (or 2-4) Directory

```
make run
```

<br></br>

# part1 code
```
open Llvm

let _ =
  let llctx = Llvm.global_context () in
  let llmem = Llvm.MemoryBuffer.of_file Sys.argv.(1) in
  let llm = Llvm_bitreader.parse_bitcode llctx llmem in
  Llvm.dump_module llm ;
  ()

```

- Makefile에서 .ml 파일을 컴파일한 .byte 실행 파일로 bitcode 분석 수행
    - `make run`
    - bitcode 파일명을 hello.bc와 다르게 사용하고 싶은 경우 Makefile 수정
    - part1 코드는 argv로 전달받은 bitcode를 dump (= print)

<br></br>

# part2 code
```
let rec print_type llty =
  let ty = Llvm.classify_type llty in
  match ty with
  | Llvm.TypeKind.Integer  -> Printf.printf "  integer\n"
  | Llvm.TypeKind.Function -> Printf.printf "  function\n"
  | Llvm.TypeKind.Array    -> Printf.printf "  array of" ; print_type (Llvm.element_type llty)
  | Llvm.TypeKind.Pointer  -> Printf.printf "  pointer to" ; print_type (Llvm.element_type llty)
  | Llvm.TypeKind.Vector   -> Printf.printf "  vector of" ; print_type (Llvm.element_type llty)
  | _                      -> Printf.printf "  other type\n"

let print_val lv =
  Printf.printf "Value\n" ;
  Printf.printf "  name %s\n" (Llvm.value_name lv) ;
  let llty = Llvm.type_of lv in
  Printf.printf "  type %s\n" (Llvm.string_of_lltype llty) ;
  print_type llty ;
  ()

let print_fun lv =
  Llvm.iter_blocks
    (fun llbb ->
      Printf.printf "  bb: %s\n" (Llvm.value_name (Llvm.value_of_block (llbb))) ;
      Llvm.iter_instrs
        (fun lli ->
          Printf.printf "    instr: %s\n" (Llvm.string_of_llvalue lli)
        )
        llbb
    )
    lv

let _ =
  let llctx = Llvm.global_context () in
  let llmem = Llvm.MemoryBuffer.of_file Sys.argv.(1) in
  let llm = Llvm_bitreader.parse_bitcode llctx llmem in
  (*Llvm.dump_module llm ;*)

  Printf.printf "*** lookup_function ***\n" ;
  let opt_lv = Llvm.lookup_function "main" llm in
  begin
  match opt_lv with
  | Some lv -> print_val lv
  | None    -> Printf.printf "'main' function not found\n"
  end ;

  Printf.printf "*** iter_functions ***\n" ;
  Llvm.iter_functions print_val llm ;

  Printf.printf "*** fold_left_functions ***\n" ;
  let count =
    Llvm.fold_left_functions
      (fun acc lv ->
        print_val lv ;
        acc + 1
      )
      0
      llm
  in
  Printf.printf "Functions count: %d\n" count ;

  Printf.printf "*** basic blocks/instructions ***\n" ;
  Llvm.iter_functions print_fun llm ;

  Printf.printf "*** iter_globals ***\n" ;
  Llvm.iter_globals print_val llm ;

  ()

```
- part2 코드는 argv로 전달받은 bitcode 내 IR의 type을 print

<br></br>

# part3 code
```
open Llvm

let _ =
  let llctx = global_context () in
  let llm = create_module llctx "mymodule" in

  let i32_t = i32_type llctx in
  let fty = function_type i32_t [| |] in

  let f = define_function "main" fty llm in
  let llbuilder = builder_at_end llctx (entry_block f) in

  let _ = build_ret (const_int i32_t 0) llbuilder in

  if Array.length Sys.argv > 1
  then print_module Sys.argv.(1) llm
  else dump_module llm ;
  ()

```
- part3 코드는 module과 function을 생성하고, builder를 통해 bitcode 생성
<br></br>

```
; ModuleID = 'mymodule'
source_filename = "mymodule"

define i32 @main() {
entry:
  ret i32 0
}
```

# part4 code
```
open Llvm

let add_target_triple triple llm =
  Llvm_X86.initialize ();
  let lltarget  = Llvm_target.Target.by_triple triple in
  let llmachine = Llvm_target.TargetMachine.create ~triple:triple lltarget in
  let lldly     = Llvm_target.TargetMachine.data_layout llmachine in

  set_target_triple (Llvm_target.TargetMachine.triple llmachine) llm ;
  set_data_layout (Llvm_target.DataLayout.as_string lldly) llm ;
  ()


let _ =
  let llctx = global_context () in
  let llm = create_module llctx "mymodule" in

  add_target_triple "x86_64" llm ;
  let i8_t = i8_type llctx in
  let i32_t = i32_type llctx in
  let fty = function_type i32_t [| |] in

  let f = define_function "main" fty llm in
  let llbuilder = builder_at_end llctx (entry_block f) in

  let printf_ty = var_arg_function_type i32_t [| pointer_type i8_t |] in
  let printf = declare_function "printf" printf_ty llm in
  add_function_attr printf Attribute.Nounwind ;
  add_param_attr (param printf 0) Attribute.Nocapture ;

  let s = build_global_stringptr "Hello, world!\n" "" llbuilder in
  (* try commenting these two lines and compare the result *)
  let zero = const_int i32_t 0 in
  let s = build_in_bounds_gep s [| zero |] "" llbuilder in

  let _ = build_call printf [| s |] "" llbuilder in

  let _ = build_ret (const_int i32_t 0) llbuilder in

  Llvm_analysis.assert_valid_module llm ;
  let _ =
    if Array.length Sys.argv > 1
    then Llvm_bitwriter.write_bitcode_file llm Sys.argv.(1) |> ignore
    else dump_module llm
  in
  ()

```
- part4 코드는 module과 function을 생성하고, builder를 통해 bitcode 생성
- main 함수에 "Hello World"를 printf 하는 IR 생성 및 삽입




---

- Bitcode 파일을 분석하기 위해서는, Llvm 모듈 내의 OCaml API를 사용하여 코드 작성
    - [llvm.moe](https://llvm.moe/ocaml/)



