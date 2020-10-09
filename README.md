# pTools
Requirements are samtools, python3, biopython and numpy. Alternatively, you can use the command below and the "requirements.txt" file in the bundle to install the dependencies:
```pip install requirements.txt
```
## BAM to pBAM conversion
This is a combination of scripts that converts BAM files into a pBAM format.
The list of corresponding folders are: (1) 10xscell/pbam/, (2) genome, (3) transcriptome
### 10xscell/pbam
This folder contains the code that converts a 10x single cell RNA-Seq BAM file into a pBAM format. The BAM file must be created by mapping the reads to the reference genome and keeping the unaligned reads in the BAM file. This folder contains the following scripts:
* PrintSequence.py
* getSeq_wN.py
* getSeq_woN.py
* makepBAM.sh
* README

Usage:
```
sh makepBAM.sh <bam> <ref>
```
* bam : input BAM file. Name of the bam file before the ".bam" extension.
* ref : input reference genome.  This should be the same reference genome that was used to generate the BAM file. Please use the full path.
* This script will generate an output "<bam>.p.bam", a pBAM file that has the same name as the input BAM file
  
### genome
This folder contains the code that converts a functional genomics BAM file into a pBAM format. This is specifically for BAM files that are created by mapping the reads to reference genome. This is the code to use for ChIP-Seq, ATAC-Seq and genome aligned RNA-Seq BAM files. This folder contains the following scripts:
* PrintSequence.py
* getSeq_wN.py
* getSeq_woN.py
* makepBAM.sh
* README

Usage:
```
sh makepBAM.sh <bam> <ref> <dir>
```
* bam : input BAM file. Name of the bam file before the ".bam" extension.
* ref : input reference genome.  This should be the same reference genome that was used to generate the BAM file. Please use the full path.
* <dir> : a path for a temporary directory. 
* This script will generate an output "<bam>.p.bam", a pBAM file that has the same name as the input BAM file
  
### transcriptome
