version 1.0

workflow 10xscell_pbam {
    meta {
        version: "1.0.1"
        caper_docker: "encodedcc/ptools:1.0.1"
    }

    input {
        File bam
        File reference_fasta
        Int cpu
        Int memory_gb
        String disk
    }
    
    call makepBAM {
        bam=bam,
        reference_fasta=reference_fasta,
        cpu=cpu,
        ramGB=ramGB,
        disk=disk,
    }
}

task makepBAM {
    input {
        File bam
        File reference_fasta
        Int cpu
        Int memory_gb 
        Int disk
    }

    String bam_prefix = basename(bam, ".bam")
    String out = bam_prefix + ".p.bam"

    command {
        $(which makepBAM_10x.sh) \ 
            ~{bam} \
            ~{ref}
    }

    output {
        File pbam = out
    }

    runtime {
        cpu: cpu
        memory: "~{resources.memory_gb} GB"
        disks: resources.disks
    }
}
