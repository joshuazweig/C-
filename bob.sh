#!/bin/sh
#Mdb lookup script

mkfifo mypipe-$$
cat mypipe-$$ | nc localhost $1 | ./cmod.sh bob.cm | bc > mypipe-$$

rm mypipe-$$
