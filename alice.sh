#!/bin/sh
#Mdb lookup script

mkfifo mypipe-$$
cat mypipe-$$ | nc -l  $1 | ./cmod.sh alice.cm | bc > mypipe-$$

rm mypipe-$$
