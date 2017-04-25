#!/bin/sh
#Mdb lookup script

mkfifo mypipe-$$
cat mypipe-$$ | nc -l  $1 | ./cmod.sh alice.cm | bc > tee  mypipe-$$

rm mypipe-$$
