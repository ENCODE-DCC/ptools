#!/bin/sh

bam_path=$1
reference_fasta=$2

bam_basename=$(basename "$bam_path")
bam_prefix=${bam_basename%.bam}


samtools view -H "${bam_path}" > header.txt
samtools view "${bam_path}" | awk '{if ($6~/N/) {print $0}}' > withN.sam
samtools view "${bam_path}" | awk '{if ($6!~/N/) {print $0}}' > withoutN.sam

python getSeq_wN.py "${reference_fasta}" header.txt withN.sam | samtools view -h -bS - > withN.p.bam
python getSeq_woN.py "${reference_fasta}" header.txt withoutN.sam | samtools view -h -bS - > withoutN.p.bam
samtools merge "${bam_prefix}".p.bam withN.p.bam withoutN.p.bam
rm header.txt
rm withN.sam
rm withoutN.sam
rm withN.p.bam
rm withoutN.p.bam
