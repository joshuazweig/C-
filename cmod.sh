#!/bin/sh

VER="3.7"
LLC="/usr/local/opt/llvm@$VER/bin/llc-$VER"
CRYPTO="/usr/lib/libcrypto.0.9.8.dylib"
TEST="$1"

while getopts "v:" c; do
    case $c in
        v) # Use Travis Paths
            LLC="/usr/lib/llvm-3.8/bin/llc"
            CRYPTO="/usr/lib/x86_64-linux-gnu/libcrypto.so.0.9.8"
            TEST="$2"
            ;;
    esac
done

#Requires you have LLI variable set (I reccomend in your bash profile) to your LLI
#may need to chmod this script to 755
basename=`echo "$TEST" | sed 's/.*\\///
                             s/.cm//'`
./cmod.native < "$TEST" > ${basename}.ll


"$LLC" ${basename}.ll > ${basename}.s

cc -o ${basename}.exe ${basename}.s special_arith.o "$CRYPTO"
./${basename}.exe
