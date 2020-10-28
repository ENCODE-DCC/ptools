#### Gamze Gursoy #####

bam_path=$1

bam_basename=$(basename "$bam_path")
bam_prefix=${bam_basename%.bam}

samtools view "${bam_path}" | python3 $(which createDiff.py) > temp.diff

python3 $(which compress.py) temp.diff "${bam_prefix}".diff

