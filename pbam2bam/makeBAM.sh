#!/bin/sh



pbam_path=$1
ref=$2
tmp=$3
run_type=$4
diff=$5

pbam_basename=$(basename "$pbam_path")
pbam_prefix=${pbam_basename%.p.bam}
#get the header
samtools view -H "${pbam_path}" > header.txt
#create bam file
samtools view "${pbam_path}" | python3 $(which pbam2bam.py) "${run_type}" "${ref}" "${diff}" "$tmp" header.txt  | samtools view -h -bS - > "${pbam_prefix}".bam
