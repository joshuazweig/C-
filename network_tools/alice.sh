#!/bin/sh
mkfifo mypipe-$$
cat mypipe-$$ | nc -l 12345 | sh cmod.sh alice.cm | tee mypipe-$$
rm mypipe-$$
