version 1.0

workflow diff {
    meta {
        version:"1.0.1"
        caper_docker:"encodedcc/ptools:1.0.1"
    }
    
    input {
        File bam
        Int cpu
        Int memory_gb
        String disk
    }

    call makediff {
        input:
            bam=bam,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }
}

task makediff {
    input {
        File bam
        Int cpu
        Int memory_gb
        String disk
    }

    String bam_prefix = basename(bam, ".bam")
    String out = bam_prefix + ".diff"

    command {
        $(which makeDiff.sh) ~{bam}
    }

    output {
        File diff = out
    }

    runtime {
        cpu: cpu
        memory: "~{memory_gb} GB"
        disks: disk
    }
}
