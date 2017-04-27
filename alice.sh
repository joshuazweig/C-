#!/bin/sh

mkfifo mypipe-$$
cat mypipe-$$ | nc -l  $1 | ./cmod.sh alice.cm > mypipe-$$

rm mypipe-$$
