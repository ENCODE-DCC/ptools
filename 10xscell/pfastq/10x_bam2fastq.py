## Gamze Gursoy  ##
## last edit: April 3rd, 2020
## input arguments
## (1) pBAM

import sys
import os
import string
import re
import csv
import zlib, sys, time, base64
import gzip
import numpy as np
import io

# python 10x_bam2fastq_v2.py chr${i}_unique.txt s${i}

fileI = gzip.open(sys.argv[1] + "_I1.fastq.gz", "w")
fileR1 = gzip.open(sys.argv[1] + "_R1.fastq.gz", "w")
fileR2 = gzip.open(sys.argv[1] + "_R2.fastq.gz", "w")


def makeI(str1, str2, str3):
    fileI.write(bytes("@" + str1 + " 1:N:0:" + str2 + "\n", encoding="utf-8"))
    fileI.write(bytest(str2 + "\n+\n", encoding="utf-8"))
    if str3 == "":
        for i in range(0, len(str2)):
            str3 = str3 + "F"
    if len(str3) < len(str2):
        for i in range(0, len(str2) - len(str3)):
            str3 = str3 + "F"
    fileI.write(bytes(str3 + "\n", encoding="utf-8"))


def makeR1(str1, str2, str3, str4, str5, str6):
    fileR1.write(bytes("@" + str1 + " 1:N:0:" + str2 + "\n", encoding="utf-8"))
    fileR1.write(bytes(str3 + str4 + "\n+\n", encoding="utf-8"))
    if str5 == "":
        for i in range(0, len(str3)):
            str5 = str5 + "F"
    if len(str5) < len(str3):
        for i in range(0, len(str3) - len(str5)):
            str5 = str5 + "F"
    if str6 == "":
        for i in range(0, len(str4)):
            str6 = str6 + "F"
    if len(str6) < len(str4):
        for i in range(0, len(str4) - len(str6)):
            str6 = str6 + "F"
    fileR1.write(bytes(str5 + str6 + "\n", encoding="utf-8"))


def makeR2(str1, str2, str3, str4):
    fileR2.write(bytes("@" + str1 + " 2:N:0:" + str2 + "\n", encoding="utf-8"))
    fileR2.write(bytes(str3 + "\n+\n", encoding="utf-8"))
    if str4 == "":
        for i in range(0, len(str3)):
            str4 = str4 + "F"
    if len(str4) < len(str3):
        for i in range(0, len(str3) - len(str4)):
            str4 = str4 + "F"
    fileR2.write(bytes(str4 + "\n", encoding="utf-8"))


fileB = sys.stdin

j = -1
for lineB in fileB:
    j = j + 1
    p = lineB.rstrip()
    pbam = p.split("\t")
    rname = str(pbam[0])
    seq = str(pbam[9])
    qual = str(pbam[10])
    nColpbam = len(pbam)
    for i in range(0, nColpbam):
        t = pbam[i].split(":")
        if t[0] == "SR":
            SR = t[2]
        if t[0] == "SY":
            SY = t[2]
        if t[0] == "CR":
            CR = t[2]
        if t[0] == "UR":
            UR = t[2]
        if t[0] == "CY":
            CY = t[2]
        if t[0] == "UY":
            UY = t[2]
    makeI(rname, SR, SY)
    makeR1(rname, SR, CR, UR, CY, UY)
    makeR2(rname, SR, seq, qual)
