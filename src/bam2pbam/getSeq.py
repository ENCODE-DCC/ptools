## Gamze Gursoy & Molly E. Green ##
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
import zlib,sys,time,base64
import gzip
import numpy as np
import PrintSequence


#following is necessary for querying sequences from reference genome
with open(sys.argv[1], 'rb') as f:
        ref=PrintSequence.Lookup(f)


bam=[]
import io

hed=open(sys.argv[2],"r")
header=[]
for line in hed:
	header.append(line.split('\n')[0])
hed.close()


for i in range(0,len(header)):
	print("%s" % header[i])

fileB = sys.stdin
RL=sys.argv[3]
for lineB in fileB:
    p=lineB.rstrip()
    pbam=p.split('\t')
    nColpbam=len(pbam)
    chrom=pbam[2]
    startPos=int(pbam[3])
    pbam[9] = ref.query(chrom, startPos-1, int(RL))
    nbam=str(pbam[0])+'\t'
    for i in range(1,nColpbam-1):
            nbam=nbam+str(pbam[i])+'\t'
    nbam=nbam+str(pbam[nColpbam-1])
    print(nbam)
    nbam=''
    bam=[]

                             
