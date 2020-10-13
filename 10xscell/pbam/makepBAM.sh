#!/bin/sh

bam=$1
ref=$2


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
