#!/bin/sh

#SBATCH -p pi_gerstein
#SBATCH -J pBAM
#SBATCH -n 1 --mem 10000 -t 144:00:00 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

module load Python
ref=$3
#ref=/ysm-gpfs/pi/gerstein/gamze/CZI/encode/ref/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta
dir=$1
bam=$2
samtools view ${dir}/${bam}.bam | awk '{if ($6~/N/) {print $0}}' > ${dir}/withN.sam
samtools view ${dir}/${bam}.bam | awk '{if ($6!~/N/) {print $0}}' > ${dir}/withoutN.sam
samtools view -H ${dir}/${bam}.bam > ${dir}/header.txt
python /ysm-gpfs/pi/gerstein/gamze/CZI/encode/code/genome/getSeq_wN.py ${ref} ${dir}/header.txt ${dir}/withN.sam | samtools view -h -bS - > ${dir}/withN.p.bam
python /ysm-gpfs/pi/gerstein/gamze/CZI/encode//code/genome/getSeq_woN.py ${ref} ${dir}/header.txt ${dir}/withoutN.sam | samtools view -h -bS - > ${dir}/withoutN.p.bam
samtools merge ${dir}/${bam}.p.bam ${dir}/withN.p.bam ${dir}/withoutN.p.bam
samtools sort ${dir}/${bam}.p.bam -o ${dir}/${bam}.sorted.p.bam
rm ${dir}/*.sam
rm ${dir}/with*.p.bam
rm ${dir}/${bam}.p.bam
rm ${dir}/header.txt
