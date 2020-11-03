version 1.0

workflow genome {
    meta {
        version:"1.0.0"
        caper_docker:"encodedcc/ptools:1.0.0"
        caper_singularity: "docker://encodedcc/ptools:1.0.0"
    }

    input {
       File bam
       File reference_fasta
       Int cpu
       Int memory_gb
       String disk
    }

    call makepbam {
        input:
            bam=bam,
            reference_fasta=reference_fasta,
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
