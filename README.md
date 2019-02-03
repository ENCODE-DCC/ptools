# bam2pbam
Pipeline to convert bams into pbams

* requires (1) python 3
         (2) samtools
         (3) picard tools
         (4) compress.py
         (5) PrintSequence.py
         (6) createDiff.py
 
* type "sh bam2pbam.sh -h" to see the options, i.e

  -q for operation <file/mis/indel/split/all>, default=all, if file then followed by the file name 

  format of the file Chr:loc-loc 

  -ft for output file type <BAM/SAM/CRAM>, default=BAM 

  -r  reference file in .gz format, mandatory 

  -in name of the input file, mandatory 

  -rl read length, default=learned from the file 

  samtools, picard and python3 should be in the path 
