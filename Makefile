.PHONY : cmod.native
cmod.native:
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis -cflags -w,+a-4 \
		cmod.native

.PHONY: scanprint
scanprint:
	ocamllex scannerprint.mll

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log *.diff cmod scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o 
	rm -rf *.err *.ll *.diff *.out
	-rm -f scannerprint.ml
.PHONY : all
all : clean cmod.native scanprint
