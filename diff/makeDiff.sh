#### Gamze Gursoy #####


tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

bam_path=$1

bam_basename=$(basename "$bam_path")
bam_prefix=${bam_basename%.bam}

echo "Creating the diff file"
samtools view "${bam_path}" | python createDiff.py > "${tmp_dir}"/temp.diff

#compress the .diff file
echo "Compressing the diff file"
python compress.py "${tmp_dir}"/temp.diff "${bam_prefix}".diff

#remove the temporary uncompressed file
rm "${tmp_dir}"/temp.diff
