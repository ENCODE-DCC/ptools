#!/bin/sh

bam_path=$1
reference_fasta=$2

bam_basename=$(basename "$bam_path")
bam_prefix=${bam_basename%.bam}


samtools view -H "${bam_path}" > header.txt
samtools view "${bam_path}" | awk '{if ($6~/N/) {print $0}}' > withN.sam
samtools view "${bam_path}" | awk '{if ($6!~/N/) {print $0}}' > withoutN.sam

python3 "$(which getSeq_wN.py)" "${reference_fasta}" header.txt withN.sam | samtools view -h -bS - > withN.p.bam
python3 "$(which getSeq_woN.py)" "${reference_fasta}" header.txt withoutN.sam | samtools view -h -bS - > withoutN.p.bam
samtools merge "${bam_prefix}".p.bam withN.p.bam withoutN.p.bam
