version 1.0

workflow transcriptome {
    meta {
        version:"1.0.1"
        caper_docker:"encodedcc/ptools:1.0.1"
    }

    input {
        File bam
        File genome_fasta
        File transcriptome_fasta
        File annotation_gtf
        Int cpu
        Int memory_gb
        String disk
    }

    call makepbam {
        input:
    }
}

task makepbam {
    input {
        File bam
        File genome_fasta
        File transcriptome_fasta
        File annotation_gtf
        Int cpu
        Int memory_gb
        String disk
    }

    String bam_prefix = basename(bam, ".bam")
    String out = bam_prefix + ".p.bam"

    command {
        $(which makepBAM_transcriptome.sh) \
            ~{bam} \
            ~{genome_fasta} \
            ~{transcriptome_fasta} \
            ~{annotation_gtf}
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
