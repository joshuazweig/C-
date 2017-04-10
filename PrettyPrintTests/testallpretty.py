import os
import difflib
import sys

cwd = os.getcwd()
for filename in os.listdir(cwd):
    if filename.endswith(".cm"):
        cmp = filename.replace('.cm','.out')
        out = filename.replace('.cm','.tmp')
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
rmout = "rm *.tmp"
os.system(rmout)
