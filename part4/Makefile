SRC_DIR:=src

TOOLS:=tutorial04

#TARGET:=native
TARGET:=byte

OCAML_VERSION := 4.11.1
LLVM_VERSION := 14
CLANG := clang-$(LLVM_VERSION)
LLC := llc-$(LLVM_VERSION)

OCAMLBUILDFLAGS:=-classic-display -j 0 -cflags -w,@a-4,-warn-error,-70
export OCAMLPATH=$(HOME)/.opam/$(OCAML_VERSION)/lib/

tutorial04_OCAMLBUILDFLAGS:=-use-ocamlfind -pkgs llvm,llvm.analysis,llvm.bitwriter,llvm.target,llvm_X86 -lflags -ccopt,-L/usr/lib/llvm-$(LLVM_VERSION)/lib




################
OCAMLBUILD:=ocamlbuild



CLEAN_RULES:=$(patsubst %,%-clean,$(TOOLS))



.PHONY: $(TOOLS) clean $(CLEAN_RULES) default run

default: $(TOOLS)

$(TOOLS):
	$(OCAMLBUILD) $(OCAMLBUILDFLAGS) $($@_OCAMLBUILDFLAGS) $($@_OCAMLBUILDFLAGS_$(TARGET)) -no-hygiene -I $(SRC_DIR) -build-dir build/$@ -r $@.$(TARGET)

clean: $(CLEAN_RULES)
	-rm -f hello hello.o hello.s hello.bc

$(CLEAN_RULES):
	$(OCAMLBUILD) $(OCAMLBUILDFLAGS) -I $(SRC_DIR) -build-dir build/$(patsubst %-clean,%,$@) -clean $(patsubst %-clean,%,$@).$(TARGET)

run: $(TOOLS) hello
	./hello

hello: hello.o
	$(CLANG) -o $@ $<

hello.o: hello.s
	$(CLANG) -c hello.s

hello.s: hello.bc
	$(LLC) $<

hello.bc: $(TOOLS)
	CAML_LD_LIBRARY_PATH=/usr/lib/ocaml/llvm-$(LLVM_VERSION) ./build/tutorial04/src/tutorial04.byte $@
