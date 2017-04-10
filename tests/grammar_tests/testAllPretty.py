import os
import difflib
import sys

exitCode = 0
testLoc = '/tests/grammar_tests/'
relTestLoc = '.' + testLoc

cwd = os.getcwd() + testLoc
for filename in os.listdir(cwd):
    if filename.endswith(".cm"):
        cmp = relTestLoc + filename.replace('.cm','.out')
        out = relTestLoc + filename.replace('.cm','.tmp')
        command = 'ocaml scannerprint.ml < ' + relTestLoc + filename +' | menhir --interpret --interpret-show-cst parser.mly > ' + out
        os.system(command)
        with open(out, 'r') as hosts0:
            with open(cmp, 'r') as hosts1:
                diff = difflib.unified_diff(
                    hosts0.readlines(),
                    hosts1.readlines(),
                    fromfile=out,
                    tofile=cmp,
                )
                for line in diff:
                    sys.stdout.write(line)
                    exitCode = 1
rmout = 'rm ' + relTestLoc + '*.tmp'
os.system(rmout)

sys.exit(exitCode)
