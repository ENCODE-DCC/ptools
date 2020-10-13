#!/bin/sh



pbam=$1
ref=$2
tmp=$3
prompt=$4


mkdir $tmp
#get the header
samtools view -H ${pbam}.p.bam > $tmp/header.txt
#create bam file
samtools view ${pbam}.p.bam | python pbam2bam.py ${prompt} ${ref} ${pbam}.diff $tmp $tmp/header.txt  | samtools view -h -bS - > $pbam\.bam
rm -rf $tmp
