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
        input:
          bam=bam,
          reference_fasta=reference_fasta,
          cpu=cpu,
          memory_gb=memory_gb,
          disk=disk,
    }
}

task makepBAM {
    input {
        File bam
        File reference_fasta
        Int cpu
        Int memory_gb 
        String disk
    }

    String bam_prefix = basename(bam, ".bam")

    command {
        cd /software/genome
        ./makepBAM.sh ~{bam} ~{reference_fasta}
    }

    output {
        File pbam = "genome/~{bam_prefix}.p.bam"
    }

    runtime {
        cpu: cpu
        memory: "~{memory_gb} GB"
        disks: disk
    }
}
