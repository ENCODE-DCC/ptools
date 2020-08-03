#!/bin/sh

#SBATCH -p pi_gerstein
#SBATCH -J pFastq
#SBATCH -n 1 --mem 50000 -t 300:00:00 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

pbam=$1
module load Python
samtools view ${pbam}.p.bam | python make_unique.py > reads.txt
awk '!seen[$1$2$3$4]++' reads.txt > unique_reads.txt
rm reads.txt
awk '{print $5}' unique_reads.txt > linenumbers.txt
rm unique_reads.txt
samtools view ${pbam}.bam | python print_unique.py | samtools view -h -bS - > filtered.bam
rm linenumbers.txt
rm header.txt
bam=filtered.bam
samtools view ${bam} | python 10x_bam2fastq.py pbam
