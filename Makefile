CC = gcc

.PHONY: cmod.native
cmod.native:
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis -cflags -w,+a-4 \
		cmod.native

.PHONY: test_grammar
test_grammar:
	ocamllex scannerprint.mll
	python tests/grammar_tests/testAllPretty.py

.PHONE: test_compiler_travis
test_compiler_travis:
	./testall.sh -v


spec_add: spec_add.c
	clang -c spec_add.c

.PHONY: clean
clean :
	ocamlbuild -clean
	rm -rf testall.log *.diff cmod scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o 
	rm -rf *.err *.ll *.diff *.out
	-rm -f scannerprint.ml *.tmp

.PHONY : all
all : clean cmod.native spec_add.o
