CC = gcc

.PHONY: cmod.native
cmod.native:
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis -cflags -w,+a-4 \
		cmod.native

.PHONY: test_grammar
test_grammar:
	ocamllex scannerprint.mll
	python tests/grammar_tests/testAllPretty.py

.PHONY: test_compiler_travis
test_compiler_travis:
	./testall.sh -v


special_arith.o: special_arith.c
	clang -I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib -c special_arith.c

access.o: access.c
	clang -c access.c

.PHONY: clean
clean :
	ocamlbuild -clean
	rm -rf testall.log *.diff cmod scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o 
	rm -rf *.err *.ll *.diff *.out
	-rm -f scannerprint.ml *.tmp
	rm -f *.exe *.s 
.PHONY : all
all : clean cmod.native special_arith.o access.o
