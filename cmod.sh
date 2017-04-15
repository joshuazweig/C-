#!/bin/sh

#Requires you have LLI variable set (I reccomend in your bash profile) to your LLI
#may need to chmod this script to 755
basename=`echo $1 | sed 's/.*\\///
                             s/.cm//'`
./cmod.native < $1 > ${basename}.ll

#Replace with your llvm compiler 
/usr/local/opt/llvm\@3.8/bin/llc-3.8 ${basename}.ll > ${basename}.s

cc -o ${basename}.exe ${basename}.s spec_add.o /usr/lib/libcrypto.0.9.8.dylib
./${basename}.exe