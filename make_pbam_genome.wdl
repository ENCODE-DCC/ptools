version 1.0


import "wdl/subworkflows/maybe_decompress.wdl" as reference


workflow genome {
    meta {
        version:"1.0.1"
        caper_docker:"encodedcc/ptools:1.0.1"
        caper_singularity: "docker://encodedcc/ptools:1.0.1"
    }

    input {
       File bam
       File? reference_fasta
       File? reference_fasta_gz
       Int cpu
       Int memory_gb
       String disk
    }

    call reference.maybe_decompress {
        input:
            input_plain=reference_fasta,
            input_gz=reference_fasta_gz,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk
    }

    call makepbam {
        input:
            bam=bam,
            reference_fasta=maybe_decompress.out,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }
}

task makepbam {
    input {
        File bam
        File reference_fasta
        Int cpu
        Int memory_gb 
        String disk
    }

    String bam_prefix = basename(bam, ".bam")
    String out = bam_prefix + ".sorted.p.bam"

    command {
        $(which makepBAM_genome.sh) \
            ~{bam} \
            ~{reference_fasta}
    }

    output {
        File pbam = out
    }

    runtime {
        cpu: cpu
        memory: "~{memory_gb} GB"
        disks: disk
    }
}
