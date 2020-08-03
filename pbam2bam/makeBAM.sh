#!/bin/sh

#SBATCH -p pi_gerstein
#SBATCH -J pBAM
#SBATCH -n 1 --mem 10000 -t 144:00:00 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

module load Python
####### Gamze Gursoy ########

pbam=$1
ref=$2
tmp=$3
prompt=$4


mkdir $tmp
#get the header
samtools view -H ${pbam}.p.bam > $tmp/header.txt
#create bam file
samtools view ${pbam}.p.bam | python pbam2bam.py ${prompt} ${ref} ${pbam}.diff $tmp $tmp/header.txt  | samtools view -h -bS - > $pbam\.bam
rm -rf $tmp
