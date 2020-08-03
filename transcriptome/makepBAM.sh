#!/bin/sh

#SBATCH -p pi_gerstein
#SBATCH -J tr-pbam-r1 -t 150:00:00
#SBATCH -c 1 --mem-per-cpu=20000


module load Python
bam=$1
samtools view -H ${bam}.bam > header.txt
gref=$2
#gref=/ysm-gpfs/pi/gerstein/gamze/CZI/encode/ref/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta
tref=$3
#tref=/ysm-gpfs/pi/gerstein/gamze/CZI/encode/ref/gencode.v24.transcripts.fa
hed=header.txt
gtf=$4
#gtf=/ysm-gpfs/pi/gerstein/gamze/CZI/encode/ref/ENCFF824ZKD.gtf

samtools view ${bam}.bam | python /ysm-gpfs/pi/gerstein/gamze/CZI/encode/code/transcriptome/pbam_mapped_transcriptome.py ${tref} ${gref} ${hed} ${gtf} | samtools view -h -bS > ${bam}.p.bam

