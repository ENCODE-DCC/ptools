version 1.0

workflow tenxscell_pfastq {
    meta {
        version:"1.0.1"
        caper_docker:"encodedcc/ptools:1.0.1"
        caper_singularity: "docker://encodedcc/ptools:1.0.1"
    }

    input {
        File pbam
        Int cpu
        Int memory_gb
        String disk
    }

    call makeFastq {
        input:
            pbam=pbam,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }
}

task makeFastq {
    input {
        File pbam
        Int cpu
        Int memory_gb
        String disk
    }

    String pbam_prefix = basename(pbam, ".bam")
    String I1_fastq = pbam_prefix + "_I1.fastq.gz"
    String R1_fastq = pbam_prefix + "_R1.fastq.gz"
    String R2_fastq = pbam_prefix + "_R2.fastq.gz"

    command {
        $(which makeFastq.sh) \
            ~{pbam}
    }

    output {
        File I1_fastq = I1_fastq
        File R1_fastq = R1_fastq
        File R2_fastq = R2_fastq
    }

    runtime {
        cpu: cpu
        memory: "~{memory_gb} GB"
        disks: disk
    }
}
