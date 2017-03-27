#!/bin/sh

#Requires you have LLI variable set (I reccomend in your bash profile) to your LLI
#may need to chmod this script to 755

echo `./cmod.native < $1 | $LLI`
