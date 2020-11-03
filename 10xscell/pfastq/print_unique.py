## Gamze Gursoy ##

import sys

bam = []

f = open("linenumbers.txt", "r")
hed = open("header.txt", "r")
header = []
for line in hed:
    header.append(line.split("\n")[0])
hed.close()

for i in range(0, len(header)):
    print("%s" % header[i])

k = 0
fileB = sys.stdin
lines = fileB.readlines()
for line in f:
    p = line.split("\n")
    ind = int(p[0])
    print(lines[ind].split("\n")[0])
f.close()
