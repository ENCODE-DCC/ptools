#!/bin/sh



bam_path=$1
gref=$2
tref=$3
hed=header.txt
gtf=$4

bam_basename=$(basename "$bam_path")
bam_prefix=${bam_basename%.bam}

samtools view -H "${bam_path}" > header.txt
samtools view "${bam_path}" | python pbam_mapped_transcriptome.py "${tref}" "${gref}" "${hed}" "${gtf}" | samtools view -h -bS > "${bam_prefix}".p.bam
