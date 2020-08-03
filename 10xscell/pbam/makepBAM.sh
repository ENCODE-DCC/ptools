#!/bin/sh

#SBATCH -p general
#SBATCH -J pBAM
#SBATCH -n 1 --mem 10000 -t 144:00:00 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email


bam=$1
ref=$2
#../../code/10x/GRCh38.p10.genome.fa


module load Python
samtools view -H ${bam}.bam > header.txt
samtools view ${bam}.bam | awk '{if ($6~/N/) {print $0}}' > withN.sam
samtools view ${bam}.bam | awk '{if ($6!~/N/) {print $0}}' > withoutN.sam

python getSeq_wN.py ${ref} header.txt withN.sam | samtools view -h -bS - > withN.p.bam
python getSeq_woN.py ${ref} header.txt withoutN.sam | samtools view -h -bS - > withoutN.p.bam
samtools merge ${bam}.p.bam withN.p.bam withoutN.p.bam
rm header.txt
rm withN.sam
rm withoutN.sam
rm withN.p.bam
rm withoutN.p.bam
