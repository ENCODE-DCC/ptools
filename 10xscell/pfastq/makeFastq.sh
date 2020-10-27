#!/bin/sh


pbam_path=$1

pbam_basename=$(basename "$pbam_path")
pbam_prefix=${pbam_basename%.bam}

samtools view -H "${pbam_path}" > header.txt
samtools view "${pbam_path}" | python3 "$(which make_unique.py)" > reads.txt
awk '!seen[$1$2$3$4]++' reads.txt > unique_reads.txt
awk '{print $5}' unique_reads.txt > linenumbers.txt
samtools view "${pbam_path}" | python3 "$(which print_unique.py)" | samtools view -h -bS - > filtered.bam
samtools view filtered.bam | python3 "$(which 10x_bam2fastq.py)" "${pbam_prefix}"
