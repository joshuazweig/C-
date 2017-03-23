import os
import difflib
import sys

cwd = os.getcwd()
for filename in os.listdir(cwd):
    if filename.endswith(".txt"):
        cmp = filename.replace('.txt','.mc')
        out = filename.replace('.txt','.out')
        command = 'ocaml ../scannerprint.ml < '+ filename +' | menhir --interpret --interpret-show-cst ../parser.mly > ' + out
        os.system(command)
        with open('./' + out, 'r') as hosts0:
            with open('./' + cmp, 'r') as hosts1:
                diff = difflib.unified_diff(
                    hosts0.readlines(),
                    hosts1.readlines(),
                    fromfile=out,
                    tofile=cmp,
                )
                for line in diff:
                    sys.stdout.write(line)
rmout = "rm *.out"
os.system(rmout)
