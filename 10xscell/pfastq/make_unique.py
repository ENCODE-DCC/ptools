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



#filein=open(sys.argv[1],'r')



fileB = sys.stdin


j=-1
for lineB in fileB:
	j=j+1
	p = lineB.rstrip()
	pbam = p.split('\t')
	rname=str(pbam[0])
	seq=str(pbam[9])
	qual=str(pbam[10])
	nColpbam=len(pbam)
	for i in range(0,nColpbam):
		t=pbam[i].split(':')
		if t[0]=="SR":
			SR=t[2]
		if t[0]=="SY":
			SY=t[2]
		if t[0]=="CR":
			CR=t[2]
		if t[0]=="UR":
			UR=t[2]
		if t[0]=="CY":
			CY=t[2]
		if t[0]=="UY":
			UY=t[2]
	print("%s %s %s %s %d" %(rname,SR,CR,UR,j))

