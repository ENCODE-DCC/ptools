import sys
import os
import string
import re
import csv


def MakeDiff(BAM):
    readarray = BAM.split("\t")
    readID = readarray[0]
    seq = readarray[9]
    Qualseq = readarray[10]
    cigar = readarray[5]
    AS = []
    MD = []
    NM = []
    MDcolumn = -1
    AScolumn = -1
    NMcolumn = -1
    for i in range(0, len(readarray)):
        chars = set("SHIDX")
        if "AS:" in readarray[i] and i > 10:
            AScolumn = i
            break
    for i in range(0, len(readarray)):
        chars = set("SHIDX")
        if "MD:Z:" in readarray[i] and i > 10:
            MDcolumn = i
            break
    for i in range(0, len(readarray)):
        chars = set("SHIDX")
        if "NM:i:" in readarray[i] and i > 10:
            NMcolumn = i
            break
    if AScolumn == -1:
        AS = ""
    else:
        a = readarray[AScolumn].split("\n")
        AS = a[0]
    if MDcolumn == -1:
        MD = ""
    else:
        a = readarray[MDcolumn].split("\n")
        MD = a[0]
    if NMcolumn == -1:
        NM = ""
    else:
        a = readarray[NMcolumn].split("\n")
        NM = a[0]
    if any((c in chars) for c in cigar):
        fseq = getfseq(cigar, seq)
        print("%s\t%s\t%s\t%s\t%s" % (cigar, fseq, AS, MD, NM))
    else:
        print("d\t%s\t%s\t%s" % (AS, MD, NM))


def cigparse(cigar):
    l1 = []
    num1 = ""
    for c1 in cigar:
        if c1 in "0123456789":
            num1 = num1 + c1
        else:
            l1.append([int(num1), c1])
            num1 = ""
    return l1


def getfseq(cigar, seq):
    a = cigparse(cigar)
    # b is the sequence
    b = seq
    start = 0
    m = ""
    k = ""
    for i in range(0, len(a)):
        if a[i][1] in "M":
            start = start + a[i][0]
            k = ""
        if a[i][1] in "N":
            start = start
            k = ""
        if a[i][1] in "SIX":
            tup = b[start : start + a[i][0]]
            k = tup + ":" + str(a[i][1]) + "-"
            start = start + a[i][0]
        m = m + k
    return m[0 : len(m) - 1]


for line in sys.stdin:
    MakeDiff(line)
