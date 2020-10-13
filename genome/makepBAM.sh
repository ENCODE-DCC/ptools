#!/bin/sh

ref=$3
dir=$1
bam=$2
samtools view ${dir}/${bam}.bam | awk '{if ($6~/N/) {print $0}}' > ${dir}/withN.sam
samtools view ${dir}/${bam}.bam | awk '{if ($6!~/N/) {print $0}}' > ${dir}/withoutN.sam
samtools view -H ${dir}/${bam}.bam > ${dir}/header.txt
python getSeq_wN.py ${ref} ${dir}/header.txt ${dir}/withN.sam | samtools view -h -bS - > ${dir}/withN.p.bam
python getSeq_woN.py ${ref} ${dir}/header.txt ${dir}/withoutN.sam | samtools view -h -bS - > ${dir}/withoutN.p.bam
samtools merge ${dir}/${bam}.p.bam ${dir}/withN.p.bam ${dir}/withoutN.p.bam
samtools sort ${dir}/${bam}.p.bam -o ${dir}/${bam}.sorted.p.bam
rm ${dir}/*.sam
rm ${dir}/with*.p.bam
rm ${dir}/${bam}.p.bam
rm ${dir}/header.txt
