#!/bin/sh



bam=$1
samtools view -H ${bam}.bam > header.txt
gref=$2
tref=$3
hed=header.txt
gtf=$4

samtools view ${bam}.bam | python pbam_mapped_transcriptome.py ${tref} ${gref} ${hed} ${gtf} | samtools view -h -bS > ${bam}.p.bam


