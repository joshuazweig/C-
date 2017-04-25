#!/bin/sh
#Mdb lookup script

mkfifo mypipe-$$
cat mypipe-$$ | nc -l $1 | ./cmod.sh bob.cm | bc > mypipe-$$

rm mypipe-$$
