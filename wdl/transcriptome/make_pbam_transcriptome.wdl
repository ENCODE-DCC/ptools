version 1.0

workflow transcriptome {
    meta {
        version:"1.0.0"
        caper_docker:"encodedcc/ptools:1.0.0"
        caper_singularity: "docker://encodedcc/ptools:1.0.0"
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
            bam=bam,
            genome_fasta=genome_fasta,
            transcriptome_fasta=transcriptome_fasta,
            annotation_gtf=annotation_gtf,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
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
