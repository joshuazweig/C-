#!/bin/sh

mkfifo mypipe-$$

cat pipe | nc -l 12345 | sh cmod.sh alice.cm | tee pipe 

rm mypipe-$$
