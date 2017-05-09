#!/bin/sh
mkfifo mypipe-$$
cat mypipe-$$ | nc localhost 12345 | sh cmod.sh bob.cm | tee mypipe-$$ 
rm mypipe-$$
