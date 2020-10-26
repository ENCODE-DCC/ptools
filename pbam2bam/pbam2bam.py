## Gamze Gursoy ##

import sys
import os
import string
import re
import csv
import zlib, sys, time, base64
import gzip
import numpy as np
import PrintSequence
import PrintTransSequence

# following is necessary for querying sequences from reference genome
if sys.argv[1] == "genome":
    with open(sys.argv[2], "rt") as f:
        ref = PrintSequence.Lookup(f)
if sys.argv[1] == "transcriptome":
    with open(sys.argv[2], "rt") as f:
        ref = PrintTransSequence.Lookup(f)


def ModifySequence(SOI, loc, mod):
    BB = []
    SOI_index = 0
    j = 0
    for i in range(0, len(loc)):
        modtype = loc[i][1]
        modloc = int(loc[i][0])

        if modtype == "M":
            BB.append(SOI[SOI_index : SOI_index + modloc])
            SOI_index = SOI_index + modloc

        if modtype == "I":
            BB.append(mod[j][0])
            j += 1

        if modtype == "X":
            BB.append(SOI[SOI_index : SOI_index + modloc])
            BB[i] = mod[j][0]
            SOI_index = SOI_index + len(mod[j][0])

        if modtype == "D":  # deletion
            SOI_index = SOI_index + modloc

        if modtype == "N":  # skipped region/intron/same as deletion
            SOI_index = SOI_index + modloc

        if modtype == "H":  # hardclip/ essentially the same as a deletion
            SOI_index = SOI_index + modloc  # not included in SEQ

        if (
            modtype == "S"
        ):  # for our purposes, a softclip essentially has the same effect as a mismatch
            BB.append(mod[j][0])
            j += 1
    BB = "".join(BB)
    return BB


def col1parser(col1):
    l1 = []
    num1 = ""
    for c1 in col1:
        if c1 in "0123456789":
            num1 = num1 + c1
        else:
            l1.append([int(num1), c1])
            num1 = ""
    return l1


def col2parser(col2):
    l2 = []
    num2 = ""
    for c2 in col2:
        if c2 not in ":-":
            if c2 in "NACTGactgn":
                num2 = num2 + c2
            else:
                l2.append([num2, c2])
                num2 = ""
    return l2


def countbps(
    l1,
):  # Count basepairs from diff cigar string rather than pBAM cigar string (otherwise N's are treated as true deletions, rather than introns)
    bps = 0
    for i in range(0, len(l1)):
        modloc = int(l1[i][0])
        if l1[i][1] != "D" or l1[i][1] != "H":
            bps = bps + modloc
    return bps


# Function to parse MDZ strings
def parseMDZ(string):
    bigarray = []
    num = ""
    bases = ""
    chunks = string.split(":")
    newstring = chunks[2]
    semifinalstring = re.split("([^0-9]*)", newstring)
    for i in semifinalstring:
        if not re.match(
            "\^", i
        ):  # Do not need to include deletions, because ModifySequence already took care of those
            bigarray.append(i)
    return bigarray


# Modify the sequence that came from ModifySeq based off of parsed MDZ strings
# Note 2 GG, rewrite this function after creating new diff
def ModifySeqII(seq, mdz):
    i = 0
    newseq = ""
    for j in range(len(mdz)):
        entry = mdz[j]
        if re.match("[0-9]", entry):
            if j + 1 != len(
                mdz
            ):  # note: MDZ is based off of counting from base 1, while python counts from base 0. So if we're in the last bit of the mdz column, then we need to add one to the entry. Otherwise, it will cut off the last bp.
                entry = int(entry)
                newseq = newseq + seq[i : (i + entry)]
                i = i + entry
            else:
                entry = int(entry)
                newseq = newseq + seq[i : (i + len(seq))]
        else:
            newseq = newseq + entry
            i = i + (len(entry))
    return newseq


##############################################
#############################################


def CheckAS(pBAMline):
    array = pBAMline.split("\t")
    AScolumn = -1
    for i in range(0, len(array)):
        if "AS:" in array[i]:
            AScolumn = i
            break
    return AScolumn


def CheckMD(pBAMline):
    array = pBAMline.split("\t")
    MDcolumn = -1
    for i in range(0, len(array)):
        if "MD:Z:" in array[i]:
            MDcolumn = i
            break
    return MDcolumn


def CheckNM(pBAMline):
    array = pBAMline.split("\t")
    NMcolumn = -1
    for i in range(0, len(array)):
        if "NM:" in array[i]:
            NMcolumn = i
            break
    return NMcolumn


diffile = sys.argv[3]
fp = open(diffile, "rb")
comptext = fp.read()
decompressed = zlib.decompress(comptext)
savedecomp = open(diffile + ".txt", "wb")
savedecomp.write(decompressed)
savedecomp.close()


bam = []
import io

fileA = open(diffile + ".txt", "r")

hed = open(sys.argv[4], "r")
header = []
for line in hed:
    header.append(line.split("\n")[0])
hed.close()


for i in range(0, len(header)):
    print("%s" % header[i])

fileB = sys.stdin

for lineA, lineB in zip(fileA, fileB):
    diff = lineA.rstrip()
    difflist = diff.split("\t")
    p = lineB.rstrip()
    pbam = p.split("\t")
    nColpbam = len(pbam)
    AS = CheckAS(p)
    MD = CheckMD(p)
    NM = CheckNM(p)
    for i in range(0, nColpbam):
        bam.append(pbam[i])
    chrom = pbam[2]
    startPos = int(pbam[3])
    nColdiff = len(difflist)
    if pbam[2] == "*":
        nbam = str(bam[0]) + "\t"
        for i in range(1, nColpbam - 1):
            nbam = nbam + str(bam[i]) + "\t"
        nbam = nbam + str(bam[nColpbam - 1])
        print(nbam)
        nbam = ""
        bam = []
    if "ERCC" not in pbam[0] and pbam[2] != "*":
        if difflist[0] != "d":
            cigar = difflist[0]
            bam[5] = cigar
            modcigar = difflist[1]
            MDarray = parseMDZ(difflist[CheckMD(diff)])
            l1 = col1parser(cigar)
            l2 = col2parser(modcigar)
            readlength = countbps(l1)
            SOI = ref.query(chrom, startPos - 1, readlength)
            final = ModifySequence(SOI, l1, l2)
            if len(MDarray) == 1:
                seq = final.upper()
            else:
                # seq = ModifySeqII(final.upper(), MDarray)
                seq = final.upper()
            if CheckAS(diff) != -1:
                bam[AS] = difflist[CheckAS(diff)]
            if CheckMD(diff) != -1:
                bam[MD] = difflist[CheckMD(diff)]
            if CheckNM(diff) != -1:
                bam[NM] = difflist[CheckNM(diff)]
        else:
            MDarray = parseMDZ(difflist[CheckMD(diff)])
            seq1 = pbam[9]
            if len(MDarray) == 1:
                seq = seq1.upper()
            else:
                # seq = ModifySeqII(seq1.upper(), MDarray)
                seq = seq1.upper()
            if CheckAS(diff) != -1:
                bam[AS] = difflist[CheckAS(diff)]
            if CheckMD(diff) != -1:
                bam[MD] = difflist[CheckMD(diff)]
            if CheckNM(diff) != -1:
                bam[NM] = difflist[CheckNM(diff)]
        RL = len(seq)
        qual = pbam[10]
        if len(qual) < RL:
            for i in range(0, RL - len(qual)):
                qual = qual + "F"
        if len(qual) > RL:
            for i in range(0, len(qual) - RL):
                qual = qual[:-1]
        bam[9] = seq
        bam[10] = qual
        nbam = str(bam[0]) + "\t"
        for i in range(1, nColpbam - 1):
            nbam = nbam + str(bam[i]) + "\t"
        nbam = nbam + str(bam[nColpbam - 1])
        print(nbam)
        nbam = ""
        bam = []


fileA.close()
