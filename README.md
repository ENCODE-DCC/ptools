# PTOOLS

WDL based workflows for BAM-to-PBAM-to-BAM conversions. For additional information on the protocol and file formats, see http://privaseq3.gersteinlab.org/docs/.

# REQUIREMENTS

The workflows can be run using [caper](https://github.com/ENCODE-DCC/caper). Install caper following these [installation instructions](https://github.com/ENCODE-DCC/caper#installation).

# CONTENTS

In `wdl` directory you will find workflows for all the supported formats. Alongside with each wdl file, an input json template is provided.

# WORKFLOW

## Making pbam

As an example, assume you have a bam file, that originates from bulk RNA sequencing experiment, and it has been aligned to human GRCh38 reference and you want to make a privacy-aware bam from it. The workflow you need is located in `wdl/genome/make_pbam_genome.wdl`, and the input template in `wdl/genome/genome_pbam_input_template.json`. 
Fill in the locations of your bam, and reference files into the template. Acceptable file storages in addition to your local machine are `https://`, `gs://`, `s3://`:
```json
{
    "genome.bam": "<your bam location here>",
    "genome.reference_fasta": "<GRCh38.fasta location here>",
    "genome.cpu": 1,
    "genome.memory_gb": 2,
    "genome.disk": "local-disk 20 SSD"
}
```
Save the input containing locations you your input files.

Memory and disk requirements depend on the size of the input. Good starting point for disk is 5x the size of your bam file, and for memory 16GB should be sufficient for most bam files. Most of the processes for now are single process. Parallelized version will be available in the future.

Run the workflow:
```bash
caper run -i <your_input.json> wdl/genome/make_pbam_genome.wdl -m metadata.json --docker
```

After the run finishes, the `metadata.json` containing detailed information of the run is written. In `outputs` section of the `metadata.json` you will find the location of the `pbam` file.
