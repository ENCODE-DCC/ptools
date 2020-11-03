## Gamze Gursoy ##
##last edit June 7th, 2020
## input arguments
## (1) reference transcriptome
## (2) reference genome
## (3) header
## (4) gtf file
import os
import string
import re
import csv
import zlib, sys, time, base64
import gzip
import numpy as np
import PrintTransSequence
import PrintSequence

# following is necessary for querying sequences from reference genome
# ref transcriptome
with open(sys.argv[1], "rt") as f1:
    ref = PrintTransSequence.Lookup(f1)

# ref genome
with open(sys.argv[2], "rt") as f2:
    ref2 = PrintSequence.Lookup(f2)

bam = []
import io

# header
hed = open(sys.argv[3], "r")
header = []
for line in hed:
    header.append(line.split("\n")[0])
hed.close()

for i in range(0, len(header)):
    print("%s" % header[i])


def getFromGtfandGFa(transc, pos, length):
    gtf = open(sys.argv[4], "r")
    seq = ""
    for line in gtf:
        if not line.lstrip().startswith("#"):
            g = line.rstrip()
            gt = g.split("\t")
            if gt[2] == "transcript" and transc in gt[8]:
                chrom = str(gt[0])
                posi = int(gt[3]) + pos
                seq = ref2.query(chrom, posi - 1, length)
                break
    return seq


fileB = sys.stdin
for lineB in fileB:
    p = lineB.rstrip()
    pbam = p.split("\t")
    if pbam[2] != "*":
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
        k = ref.query(chrom, startPos - 1, int(RL))
        if k == 0:
            pbam[9] = getFromGtfandGFa(chrom, startPos - 1, int(RL))
        else:
            pbam[9] = ref.query(chrom, startPos - 1, int(RL))
        pbam[5] = str(RL) + "M"
        if len(pbam[9]) < int(RL):
            a = int(RL) - len(pbam[9])
            for i in range(0, a):
                pbam[9] = pbam[9] + "N"
        pbam[9] = pbam[9].upper()
        nbam = str(pbam[0]) + "\t"
        for i in range(1, nColpbam - 1):
            nbam = nbam + str(pbam[i]) + "\t"
        nbam = nbam + str(pbam[nColpbam - 1])
        print(nbam)
        nbam = ""
        bam = []
    if pbam[2] == "*":
        print(p)
