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
import pandas as pd

bam = []
import io
f=open('linenumbers.txt','r')
hed = open('header.txt', "r")
header = []
for line in hed:
    header.append(line.split('\n')[0])
hed.close()

for i in range(0, len(header)):
    print("%s" % header[i])

k=0
fileB = sys.stdin
lines=fileB.readlines()
for line in f:
	p=line.split('\n')
        ind=int(p[0])
	print(lines[ind].split('\n')[0])

