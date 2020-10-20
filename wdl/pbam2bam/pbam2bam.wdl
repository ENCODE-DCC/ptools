version 1.0

workflow pbam2bam {
    meta {
        version:"1.0.1"
        caper_docker:"encodedcc/ptools:1.0.1"
    }

    input {
        File pbam
        File diff
        File reference_fasta
        String run_type # genome or transcriptome
        Int cpu
        Int memory_gb
        String disk
    }

    call makebam {
        input:
            pbam=pbam,
            diff=diff,
            reference_fasta=reference_fasta,
            run_type=run_type,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }
}

task makebam {
    input {
        File pbam
        File diff
        File reference_fasta
        String run_type
        Int cpu
        Int memory_gb
        String disk
    }

    String prefix = basename(pbam, ".p.bam")
    String out = prefix + ".bam"

    command {
        $(which makeBAM.sh) \
            ~{pbam} \
            ~{reference_fasta} \
            FOO \
            ~{run_type} \
            ~{diff}
    }

    output {
        File bam = out
    }

    runtime {
        cpu: cpu
        memory: "~{memory_gb} GB"
        disks: disk
    }
}
