version 1.0

workflow genome {
    meta {
        version:"1.0.1"
        caper_docker:"encodedcc/ptools:1.0.1"
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

    command {
        cd genome
        ./makepBAM.sh ~{bam} ~{ref}
    }

    output {
        File pbam = "genome/~{bam_prefix}.p.bam"
    }

    runtime {
        cpu: cpu
        memory: "~{resources.memory_gb} GB"
        disks: resources.disks
    }
}
