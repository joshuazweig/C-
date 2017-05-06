#!/bin/sh

mkfifo mypipe-$$

cat pipe2 | nc localhost 12345 | sh cmod.sh bob.cm | tee pipe2

rm mypipe-$$
