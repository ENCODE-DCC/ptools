## Gamze Gursoy ##
##last edit March 24th, 2020
## input arguments
## (1) reference genome
## (2) diff folder
## (3) diff file
## (4) tmp folder
## (5) header file
## (6) read length

import sys
import os
import string
import re
import csv
import zlib, sys, time, base64
import gzip
import numpy as np
import PrintSequence

# following is necessary for querying sequences from reference genome
with open(sys.argv[1], "rt") as f:
    ref = PrintSequence.Lookup(f)

bam = []
import io

hed = open(sys.argv[2], "r")
header = []
for line in hed:
    header.append(line.split("\n")[0])
hed.close()

for i in range(0, len(header)):
    print("%s" % header[i])

fileB = open(sys.argv[3], "r")
for lineB in fileB:
    p = lineB.rstrip()
    pbam = p.split("\t")
    RL = len(pbam[9])
    nColpbam = len(pbam)
    for i in range(0, nColpbam):
        t = pbam[i].split(":")
        if t[0] == "MD":
            pbam[i] = "MD:Z:" + str(RL)
        if t[0] == "AS":
            pbam[i] = "AS:i:" + str(RL)
        if t[0] == "NM":
            pbam[i] = "NM:i:0"
        if t[0] == "nM":
            pbam[i] = "nM:i:0"
    chrom = str(pbam[2])
    startPos = int(pbam[3])
    if pbam[5] != "*" and "chr" in chrom:
        pbam[9] = ref.query(chrom, startPos - 1, int(RL))
        pbam[5] = str(RL) + "M"
        if len(pbam[9]) < int(RL):
            a = int(RL) - len(pbam[9])
            pbam[5] = str(RL - a) + "M" + str(a) + "S"
            for i in range(0, a):
                pbam[9] = pbam[9] + "N"
    else:
        pbam[9] = pbam[9]
        pbam[5] = pbam[5]
    nbam = str(pbam[0]) + "\t"
    for i in range(1, nColpbam - 1):
        nbam = nbam + str(pbam[i]) + "\t"
    nbam = nbam + str(pbam[nColpbam - 1])
    print(nbam)
    nbam = ""
    bam = []
