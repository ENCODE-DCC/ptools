## Gamze Gursoy  ##
## last edit: March 24th, 2020
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


def ParseCigar(cigar):
    l = []
    num = ""
    for c in cigar:
        if c in "0123456789":
            num = num + c
        else:
            l.append([int(num), c])
            num = ""
    return l


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

# fileB = sys.stdin
fileB = open(sys.argv[3], "r")
# RL=len(pbam[9])
for lineB in fileB:
    p = lineB.rstrip()
    pbam = p.split("\t")
    RL = len(pbam[9])
    chrom = str(pbam[2])
    if "chr" in chrom:
        parsedCigar = ParseCigar(pbam[5])
        for i in range(0, len(parsedCigar)):
            if parsedCigar[i][1] == "N":
                midpoint = i
                break
        lenbeforemid = 0
        delLength = 0
        for i in range(0, midpoint):
            if parsedCigar[i][1] != "D":
                lenbeforemid = lenbeforemid + int(parsedCigar[i][0])
            if parsedCigar[i][1] == "D":
                delLength = int(parsedCigar[i][0])
        lenaftermid = RL - lenbeforemid
        pbam[5] = (
            str(lenbeforemid)
            + "M"
            + str(parsedCigar[midpoint][0])
            + "N"
            + str(lenaftermid)
            + "M"
        )
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
        if parsedCigar[0][1] == "S" or parsedCigar[0][1] == "D":
            startPos = int(pbam[3]) - int(parsedCigar[0][0]) + delLength
        else:
            startPos = int(pbam[3]) + delLength
        seqbefore = ref.query(chrom, startPos - 1, int(lenbeforemid))
        seqafter = ref.query(
            chrom,
            startPos + lenbeforemid + parsedCigar[midpoint][0] - 1,
            int(lenaftermid),
        )
        pbam[3] = startPos
        pbam[9] = seqbefore + seqafter
        if len(pbam[9]) < int(RL):
            b = len(pbam[9])
            a = int(RL) - len(pbam[9])
            for i in range(0, a):
                pbam[9] = pbam[9] + "N"
                if b > lenbeforemid:
                    pbam[5] = (
                        str(lenbeforemid)
                        + "M"
                        + str(parsedCigar[midpoint][0])
                        + "N"
                        + str(b - lenbeforemid)
                        + "M"
                        + str(a)
                        + "S"
                    )
                if b == lenbeforemid:
                    pbam[5] = (
                        str(lenbeforemid)
                        + "M"
                        + str(parsedCigar[midpoint][0])
                        + "N"
                        + str(a)
                        + "S"
                    )
                if b < lenbeforemid:
                    pbam[5] = str(b) + "M" + str(a) + "S"
    nbam = str(pbam[0]) + "\t"
    for i in range(1, nColpbam - 1):
        nbam = nbam + str(pbam[i]) + "\t"
    nbam = nbam + str(pbam[nColpbam - 1])
    print(nbam)
    nbam = ""
    bam = []
