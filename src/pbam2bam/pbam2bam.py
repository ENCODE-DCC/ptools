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


def ModifySequence(SOI, loc, mod, rl):
        BB=[]
        SOI_index=0;
        j=0
        for i in xrange(0,len(loc)):
                modtype=loc[i][1]
                modloc=int(loc[i][0])
		if (modtype == "M"):
                	BB.append(SOI[SOI_index:SOI_index+modloc])
                	SOI_index = (SOI_index + modloc)

        	if (modtype == "I"):
                	BB.append(mod[j][0])
                	j+=1

        	if (modtype == "X"):
                	BB.append(SOI[SOI_index:SOI_index+modloc])
                	BB[i]=mod[j][0]
                	SOI_index = SOI_index + len(mod[j][0])
                	if (len(mod) > 1):
                        	j=j+1

        	if (modtype == "D"): #deletion
                	BB.append(' ')
                	SOI_index = SOI_index + modloc

        	if (modtype == "N"): #skipped region/intron/same as deletion
                	BB.append(' ')
                	SOI_index = SOI_index + modloc

        	if (modtype == "H"): #hardclip/ essentially the same as a deletion
                	BB.append(' ')
                	SOI_index = SOI_index + modloc #not included in SEQ

        	if (modtype == "S"): #for our purposes, a softclip essentially has the same effect as a mismatch 
                	BB.append(SOI[SOI_index:SOI_index+modloc])
                	BB[i]=mod[j][0]
                	SOI_index = SOI_index + len(mod[j][0])
                	if (len(mod) > 1):
                        	j=j+1
#print(BB)
	while True:
    		try:
        		BB.remove(' ')
    		except ValueError:
        		break
	BB="".join(BB)
        return BB


def col1parser(col1):
    l1 = []
    num1 = ""
    for c1 in col1:
        if c1 in '0123456789':
            num1 = num1 + c1
        else:
            l1.append([int(num1), c1])
            num1 = ""
    return l1

def col2parser(col2):
    l2 = []
    num2 = ""
    for c2 in col2:
        if c2 not in ':-':
            if (c2 in 'NACTGactgn'):
                num2 = num2 + c2
            else:
                l2.append([num2, c2])
                num2 = ""
    return l2


def countbps(l1):       # Count basepairs from diff cigar string rather than pBAM cigar string (otherwise N's are treated as true deletions, rather than introns)
        bps=0
        for i in xrange(0,len(l1)):
                modloc=int(l1[i][0])
                bps=bps+modloc
        return bps


#Function to parse MDZ strings
def parseMDZ(string):
        bigarray=[]
        num=''
        bases=''
        chunks=string.split(':')
        newstring=chunks[2]
        semifinalstring=re.split('([^0-9]*)', newstring)
        for i in semifinalstring:
                if not re.match('\^', i): # Do not need to include deletions, because ModifySequence already took care of those
                        bigarray.append(i)
        return bigarray


#Modify the sequence that came from ModifySeq based off of parsed MDZ strings
def ModifySeqII(seq, mdz):
        i=0
        newseq=""
        for j in range(len(mdz)):
                entry=mdz[j]
                if re.match('[0-9]', entry):
                        if j+1 != len(mdz): #note: MDZ is based off of counting from base 1, while python counts from base 0. So if we're in the last bit of the mdz column, then we need to add one to the entry. Otherwise, it will cut off the last bp.
                                entry = int(entry)
                                newseq = newseq + seq[i:(i+entry)]
                                i=(i+entry)
                        else:
                                entry=int(entry)
                                newseq = newseq + seq[i:(i+len(seq))]
                else:
                        newseq =  newseq + entry
                        i = i+(len(entry))
        return newseq



##############################################
#############################################



def CheckAS(pBAMline):
	array=pBAMline.split('\t')
	AScolumn=-1
	for i in range(0,len(array)):
		if 'AS:' in array[i] and i>10:
                        AScolumn=i
                        break
	return(AScolumn)


def CheckMD(pBAMline):
        array=pBAMline.split('\t')
        MDcolumn=-1
        for i in range(0,len(array)):
                if 'MD:Z:' in array[i] and i>10:
                        MDcolumn=i
                        break
        return(MDcolumn)


def decompress(diff,tmpfolder):
	fp=open(diff,"rb")
	comptext = fp.read()
	decompressed = zlib.decompress(comptext)

diffolder=sys.argv[2]
diffile=sys.argv[3]
tmpfolder=sys.argv[4]
fp=open(diffolder+'/'+diffile,"rb")
comptext = fp.read()
decompressed = zlib.decompress(comptext)
savedecomp = open(tmpfolder+'/'+diffile+'.txt', 'wb')
savedecomp.write(decompressed)
savedecomp.close()


bam=[]
import io

fileA = open(tmpfolder+'/'+diffile+'.txt',"r")

hed=open(sys.argv[5],"r")
header=[]
for line in hed:
	header.append(line.split('\n')[0])
hed.close()


for i in range(0,len(header)):
	print("%s" % header[i])

fileB = sys.stdin
RL=sys.argv[6]
for lineA, lineB in zip(fileA, fileB):
    diff=lineA.rstrip()
    difflist=diff.split('\t')
    p=lineB.rstrip()
    pbam=p.split('\t')
    AS=CheckAS(p)
    MD=CheckMD(p)
    nColpbam=len(pbam)
    for i in range(0,nColpbam):
           bam.append(0)
    chrom=pbam[2]
    startPos=int(pbam[3])
    nColdiff=len(difflist)
    if 'ERCC' not in pbam[0]:
        if AS!=-1 and MD!=-1 and nColdiff==5:
                cigar=difflist[0]
                modcigar=difflist[1]
                MDarray=parseMDZ(difflist[4])
                l1=col1parser(cigar)
       	        l2=col2parser(modcigar)
       		readlength=countbps(l1)
                SOI=ref.query(chrom, startPos-1, readlength)
                final=ModifySequence(SOI, l1, l2, readlength)
		if (len(MDarray)==1):
			seq=final.upper()
		else:
			seq=ModifySeqII(final.upper(),MDarray)
                qual=pbam[10]
                pbam[AS]=difflist[CheckAS(diff)]
                pbam[MD]=difflist[CheckMD(diff)]
                for i in range(0,5):
                      bam[i]=pbam[i]
                bam[5]=cigar;
                for i in range(6,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]
        if AS!=-1 and MD!=-1 and nColdiff==3:
                MDarray=parseMDZ(difflist[2])
		readlength=int(RL)
                SOI=ref.query(chrom, startPos-1, readlength)
		final=SOI
		if (len(MDarray)==1):
                        seq=final.upper()
                else:
                        seq=ModifySeqII(final.upper(),MDarray)
                qual=pbam[10]
                pbam[AS]=difflist[CheckAS(diff)]
                pbam[MD]=difflist[CheckMD(diff)]
                for i in range(0,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]
        if AS==-1 and MD!=-1 and nColdiff==4:
		cigar=difflist[0]
                MDarray=parseMDZ(difflist[3])
                modcigar=difflist[1]
                l1=col1parser(cigar)
                l2=col2parser(modcigar)
                readlength=countbps(l1)
                SOI=ref.query(chrom, startPos-1, readlength)
                final=ModifySequence(SOI, l1, l2, readlength)
                if (len(MDarray)==1):
                        seq=final.upper()
                else:
                        seq=ModifySeqII(final.upper(),MDarray)
		qual=pbam[10]
                pbam[MD]=difflist[CheckMD(diff)]
                for i in range(0,5):
                      bam[i]=pbam[i]
                bam[5]=cigar;
                for i in range(6,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]
				
        if AS==-1 and MD!=-1 and nColdiff==2:
                MDarray=parseMDZ(difflist[1])
		readlength=int(RL)
                SOI=ref.query(chrom, startPos-1, readlength)
		final=SOI
		if (len(MDarray)==1):
                        seq=final.upper()
                else:
                        seq=ModifySeqII(final.upper(),MDarray)
                qual=pbam[10]
                pbam[MD]=difflist[CheckMD(diff)]
                for i in range(0,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]
        
        if AS!=-1 and MD==-1 and nColdiff==4:
                cigar=difflist[0]
                modcigar=difflist[1]
                l1=col1parser(cigar)
                l2=col2parser(modcigar)
	        readlength=countbps(l1)
                SOI=ref.query(chrom, startPos-1, readlength)
                final=ModifySequence(SOI, l1, l2,readlength)
                seq=final.upper()
                qual=pbam[10]
                pbam[AS]=difflist[CheckAS(diff)]
                for i in range(0,5):
                      bam[i]=pbam[i]
                bam[5]=cigar;
                for i in range(6,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]

        if AS!=-1 and MD==-1 and nColdiff==2:
		readlength=int(RL)
                SOI=ref.query(chrom, startPos-1, readlength)
                seq=SOI.upper()
                qual=pbam[10]
                pbam[AS]=difflist[CheckAS(diff)]
                for i in range(0,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]
	
        if AS==-1 and MD==-1 and nColdiff==1:
		readlength=int(RL)
                SOI=ref.query(chrom, startPos-1, readlength)
                seq=SOI.upper()
                qual=pbam[10]
                for i in range(0,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                       bam[i]=pbam[i]

        if AS==-1 and MD==-1 and nColdiff==3:
                cigar=difflist[0]
                modcigar=difflist[1]
                l1=col1parser(cigar)
                l2=col2parser(modcigar)
                readlength=countbps(l1)
                SOI=ref.query(chrom, startPos-1, readlength)
                final=ModifySequence(SOI, l1, l2,readlength)
                seq=final.upper()
                qual=pbam[10]
                for i in range(0,5):
                      bam[i]=pbam[i]
                bam[5]=cigar;
                for i in range(6,9):
                      bam[i]=pbam[i]
                bam[9]=seq
                bam[10]=qual
                for i in range(11,nColpbam):
                      bam[i]=pbam[i]
	if len(bam[9])<int(RL):
                a=int(RL)-len(bam[9])
                for i in range(0,a):
                        bam[9] = bam[9] + "N"
        nbam=str(bam[0])+'\t'
        for i in range(1,nColpbam-1):
                nbam=nbam+str(bam[i])+'\t'
        nbam=nbam+str(bam[nColpbam-1])
        print(nbam)
        nbam=''
        bam=[]


fileA.close()


                                 
