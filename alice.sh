#!/bin/sh

mkfifo mypipe-$$
cat mypipe-$$ | nc -l  $1 | ./cmod.sh alice.cm | bc > mypipe-$$

rm mypipe-$$
