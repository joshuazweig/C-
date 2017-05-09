#!/bin/sh

#Requires you have LLI variable set (I reccomend in your bash profile) to your LLI
#may need to chmod this script to 755

VER="3.8"
LLC="/usr/local/opt/llvm@$VER/bin/llc-$VER"
CRYPTO="/usr/lib/libcrypto.0.9.8.dylib"
TEST="$2"

usage() { echo "Usage: $0 [-h help] [-t token] [-a ast] [-l llvm] [-c ll-file] [-s s-file] [-e exe-file] <file-name>.cm" 1>&2; exit 1; }

help() { echo "\n Welcome to the C% compiler CMC! 
	\n USAGE: $0 [-h help] [-t token] [-a ast] [-l llvm] [-c ll-file] [-s s-file] [-e exe-file] <file-name>.cm\n 
	\n OPTIONS:
	-h 	help  		This option prints this message!\n
	-t	token		This option prints the tokenized program to stdout.\n
	-a 	ast 		This option prints the abstract syntax tree of the program to stdout.\n
	-l 	llvm		Compiles <file-name>.cm to llvm and prints the result to stdout.\n
	-c 	ll-file		Compiles <file-name>.cm to llvm and puts the result in <file-name>.ll. This is the default option.\n
	-s 	assembly	Compiles <file-name>.cm to llvm, translates to assembly, and puts the result in <file-name>.s 
					(leaves <file-name>.ll in directory as well)\n
	-e 	executable	Creates the executable version of <file-name>.cm, simply called <file-name> to be run ./<file-name> 
					(leaves behind the corresponding .ll and .s files as well)\n" 1>&2; exit 1; }

if getopts "h:t:a:l:c:s:e:" c; then
	basename=`echo "$TEST" | sed 's/.*\\///
                             s/.cm//'`

    case $c in
        h) # help
			help
			;;
		t) # print tokenized program
			ocamllex scannerprint.mll
			ocaml scannerprint.ml < "$TEST"
			;;
		a) # print the AST to stdout
			ocamllex scannerprint.mll
                        ocaml scannerprint.ml < "$TEST" | menhir --interpret --interpret-show-cst parser.mly
			# ./cmod.native -a < "$TEST"
			;;
		l) # compile to llvm, print to stdout
			./cmod.native < "$TEST"
			;;
		c) # compile to llvm, put in .ll file
			./cmod.native < "$TEST" > ${basename}.ll
			;;
		s) # translate to .s file
			./cmod.native < "$TEST" > ${basename}.ll
			"$LLC" ${basename}.ll > ${basename}.s
			;;
		e) # create executable
			./cmod.native < "$TEST" > ${basename}.ll
			"$LLC" ${basename}.ll > ${basename}.s
			cc -o ${basename} ${basename}.s special_arith.o access.o "$CRYPTO"
			;;
		*) # everything else
			usage
			;;
    esac
else
	# DEFAULT
	TEST="$1"
	basename=`echo "$TEST" | sed 's/.*\\///
                             s/.cm//'`
	./cmod.native < "$TEST" > ${basename}.ll

	"$LLC" ${basename}.ll > ${basename}.s

	cc -o ${basename} ${basename}.s special_arith.o "$CRYPTO"
fi

