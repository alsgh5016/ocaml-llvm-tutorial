SRC_DIR:=src

TOOLS:=tutorial02

#TARGET:=native
TARGET:=byte

OCAML_VERSION := 4.11.1
LLVM_VERSION := 14
CLANG := clang-$(LLVM_VERSION)

OCAMLBUILDFLAGS:=-classic-display -j 0 -cflags -w,@a-4,-warn-error,-70
export OCAMLPATH=$(HOME)/.opam/$(OCAML_VERSION)/lib/

tutorial02_OCAMLBUILDFLAGS:=-use-ocamlfind -pkgs llvm,llvm.bitreader -lflags -ccopt,-L/usr/lib/llvm-$(LLVM_VERSION)/lib




################
OCAMLBUILD:=ocamlbuild



CLEAN_RULES:=$(patsubst %,%-clean,$(TOOLS))



.PHONY: $(TOOLS) clean $(CLEAN_RULES) default run

default: $(TOOLS)

$(TOOLS):
	$(OCAMLBUILD) $(OCAMLBUILDFLAGS) $($@_OCAMLBUILDFLAGS) $($@_OCAMLBUILDFLAGS_$(TARGET)) -no-hygiene -I $(SRC_DIR) -build-dir build/$@ -r $@.$(TARGET)

run: $(TOOLS) hello.bc
	CAML_LD_LIBRARY_PATH=$(OCAMLPATH)/stublibs/ ./build/tutorial02/src/tutorial02.byte hello.bc

clean: $(CLEAN_RULES)
	-rm -f hello.bc

$(CLEAN_RULES):
	$(OCAMLBUILD) $(OCAMLBUILDFLAGS) -I $(SRC_DIR) -build-dir build/$(patsubst %-clean,%,$@) -clean $(patsubst %-clean,%,$@).$(TARGET)

hello.bc: hello.c
	$(CLANG) -c -emit-llvm $<
