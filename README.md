# PTOOLS

WDL based workflows for BAM-to-PBAM-to-BAM conversions. For additional information on the protocol and file formats, see http://privaseq3.gersteinlab.org/docs/.

# REQUIREMENTS

The workflows can be run using [caper](https://github.com/ENCODE-DCC/caper). Install caper following these [installation instructions](https://github.com/ENCODE-DCC/caper#installation).

# CONTENTS

In `wdl` directory you will find workflows for all the supported formats. Alongside with each wdl file, an input json template is provided.

# WORKFLOW

## Making pbam

As an example, assume you have a `bam` file, that originates from bulk RNA sequencing experiment, and it has been aligned to human GRCh38 reference and you want to make a privacy-aware bam from it. The workflow you need is located in `wdl/genome/make_pbam_genome.wdl`, and the input template in `wdl/genome/genome_pbam_input_template.json`. 
Fill in the locations of your `bam`, and reference files into the template. Acceptable file storages in addition to your local machine are `https://`, `gs://`, `s3://`:
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

Memory and disk requirements depend on the size of the input. Good starting point for disk is 5x the size of your `bam` file, and for memory 16GB should be sufficient for most `bam` files. Most of the processes for now are single process. Parallelized version will be available in the future.

Run the workflow:
```bash
caper run -i <your_input.json> wdl/genome/make_pbam_genome.wdl -m metadata.json --docker
```
If you are using singularity use `--singularity` option instead of `--docker`.

After the run finishes, the `metadata.json` containing detailed information of the run is written. In `outputs` section of the `metadata.json` you will find the location of the `pbam` file.
Assuming you are not intending anyone to be able to restore the information contained in the `bam` file, you are done. If you need to be able to reverse the transformation, you will need to create a `diff` file corresponding to your `bam`.

## Making diff

The workflow and corresponding input template are located in `wdl/diff` directory. As above fill in the location of the `bam` file into the template:
```
{
    "diff.bam": "<your bam location here>,
    "diff.cpu": 1,
    "diff.memory_gb": 2,
    "diff.disk": "local-disk 20 SSD"
}
```
Memory and disk requirements and running is as above.

## Restoring bam

To restore a regular `bam` from `pbam` and `diff` files you will need to use the workflow and input template located in `wdl/pbam2bam`. The process is very similar to the previous steps. Fill in the input files to the template:
```
{
    "pbam2bam.pbam": "<your pbam location here>",
    "pbam2bam.diff": "<corresponding diff location here>",
    "pbam2bam.run_type": "genome",
    "pbam2bam.reference_fasta": "<reference fasta location here>",
    "pbam2bam.cpu": 1,
    "pbam2bam.memory_gb": 2,
    "pbam2bam.disk": "local-disk 20 SSD"
}
```
Running and locating outputs is exactly same as before.
