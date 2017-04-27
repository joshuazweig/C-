import sys

def add_preprocess_name(in_file_name):
    temp = in_file_name.split('.')
    temp[-2] += "_preprocess"
    return '.'.join(temp)

def preprocess_file(in_file_name, out_file, table):
    in_file = open(in_file_name, 'r')
    wait_endif = 0
    for line in in_file:
        sys.stdout.write("%50s %s\n"%(line.rstrip('\n'), in_file_name))
        if wait_endif:
            try:
                if line.split()[0] == "#endif":
                    wait_endif = 0
            except IndexError:
                pass
        elif line.strip() == '':
            out_file.write(line)
        elif line.strip()[0] == "#":
            line = line[1:]
            tokens = line.split()
            if tokens[0] == "include":
                file_name = tokens[1].lstrip(' "').rstrip(' "')
                preprocess_file(file_name, out_file, table)
            elif tokens[0] == "define":  # just for build guards
                                         # not good for textual substitutions
                table[tokens[1]] = 1
                # change this to tokens[2] for textual substitutions, 
                # when implemented
            elif tokens[0] == "ifdef":
                if tokens[1] not in table: 
                  wait_endif = 1
            elif tokens[0] == "ifndef":
                print table
                if tokens[1] in table: 
                  wait_endif = 1
            elif tokens[0] == "endif":
                pass
            else:
                raise Exception("illegal token " + tokens[0] + " found after #")
        else:
            out_file.write(line)

def main():
    in_file_name = sys.argv[1]
    out_file_name = add_preprocess_name(in_file_name)
    out_file = open(out_file_name, 'w')
    symbol_table = {}
    preprocess_file(in_file_name, out_file, symbol_table)
    return 0

if __name__ == '__main__':
    main()
