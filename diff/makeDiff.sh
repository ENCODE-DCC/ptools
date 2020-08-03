#### Gamze Gursoy #####


bam=$1
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

echo "Creating the diff file"
samtools view ${bam}.bam | python createDiff.py > ${tmp_dir}/temp.diff

#compress the .diff file
echo "Compressing the diff file"
python compress.py ${tmp_dir}/temp.diff ${bam}.diff

#remove the temporary uncompressed file
rm ${tmp_dir}/temp.diff

