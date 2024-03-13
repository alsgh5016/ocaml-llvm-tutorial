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

- opam install llvm 혹은 llvm-15 이상의 버전으로 설치하면, opam과 ocamlfind 사이에 version conflict가 발생함

## Run Makefile in part1 (or 2-4) Directory

```
make run
```