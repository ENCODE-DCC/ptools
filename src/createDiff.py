import sys
import os
import string
import re
import csv
'''
README:

Name: Final_Bam_2_pBAM_and_Diff.py

Authors: Molly Green, Gamze Gursoy (editor)

Purpose: Convert a BAM file into two tab-separated .txt files, a pBAM file and a Diff file.

	- The pBAM consists of the ReadID, Chromosome, Position on that chromosome, and the read length.
	- The Diff file consists of the ReadID, the Sequence, the QualSeq, the CIGAR string, and a modification string.

Usage (terminal, in bash, with Python installed as a module): 

$ Module load Python
$ python Final_Bam_2_pBAM_and_Diff.py path/to/BAM.bam  desired/path/to/pBAM.txt desired/path/to/diff.txt 


Program has ______ parts, each is described in detail below:

1) Try.py -  One function
		MakeDiff is passed a non-human-readable BAM file and returns a readable SAM file, line by line.   
2) CigarToMod.py - Two functions
		cigparse - 
		cigmod - 

3) MakepBAM.py
'''

#Try.py

def MakeDiff(BAM):
	readarray = BAM.split('\t')
	readID = readarray[0]
	seq = readarray[9]
	Qualseq = '*'
	cigar =  readarray[5]
	AS=[]
	MD=[]
	MDcolumn=-1
	AScolumn=-1
	for i in range(0,len(readarray)):
		chars=set('SHIDX')
		if 'AS:' in readarray[i] and i>10:
                        AScolumn=i
                        break
	for i in range(0,len(readarray)):
		chars=set('SHIDX')
		if 'MD:Z:' in readarray[i] and i>10:
			MDcolumn=i
			break
	if AScolumn==-1 and MDcolumn==-1:
		if any((c in chars) for c in cigar):
			fseq=getfseq(cigar,seq)
			print("%s\t%s\t%s" % (cigar, fseq, Qualseq))
		else:
			print("%s" % (Qualseq))
	elif AScolumn!=-1 and MDcolumn==-1:
		if any((c in chars) for c in cigar):
			fseq=getfseq(cigar,seq)
			AS=readarray[AScolumn]
			print("%s\t%s\t%s\t%s" % (cigar, fseq, Qualseq, AS))
		else:
			AS=readarray[AScolumn]
			print("%s\t%s" % (Qualseq, AS))
	elif AScolumn==-1 and MDcolumn!=-1:
		if any((c in chars) for c in cigar):
			fseq=getfseq(cigar,seq)
			a=readarray[MDcolumn].split("\n")
			MD=a[0]
			print("%s\t%s\t%s\t%s" % (cigar, fseq, Qualseq, MD))
		else:
			a=readarray[MDcolumn].split("\n")
			MD=a[0]
			print("%s\t%s" % (Qualseq, MD))
	else:
		if any((c in chars) for c in cigar):
			fseq=getfseq(cigar,seq)
			a=readarray[MDcolumn].split("\n")
			MD=a[0]
			AS=readarray[AScolumn]
			print("%s\t%s\t%s\t%s\t%s" % (cigar, fseq, Qualseq, AS, MD))
		else:
			a=readarray[MDcolumn].split("\n")
			MD=a[0]
			AS=readarray[AScolumn]
			print("%s\t%s\t%s" % (Qualseq, AS, MD))

      

def cigparse(cigar):
	l1 = []
	num1 = ""
	for c1 in cigar:
		if c1 in '0123456789':
			num1 = num1 + c1
		else:
			l1.append([int(num1), c1])
			num1 = ""
	return(l1) #Remember to change 'print' back to 'return' after sanity check

def getfseq(cigar,seq): 
	a=cigparse(cigar)
#	print(a)
#b is the sequence
	b=seq
	start=0
	m='';
#print(len(a))
	for i in range(0,len(a)):
		if a[i][1] in 'M':
			start=start+a[i][0]
			k=''
		if a[i][1] in 'N':
			start=start
			k=''
		if a[i][1] in 'SIX':
			tup=b[start:start+a[i][0]]
		#	print(tup)
			k=tup+':'+str(a[i][1])+'-'
			start=start+a[i][0]
		m=m+k
#       print(m)
	return(m[0:len(m)-1])  


for line in sys.stdin:
	MakeDiff(line)                                     
