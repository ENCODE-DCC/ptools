version 1.0

import "../subworkflows/maybe_decompress.wdl" as reference


workflow transcriptome {
    meta {
        version:"1.0.0"
        caper_docker:"encodedcc/ptools:1.0.0"
        caper_singularity: "docker://encodedcc/ptools:1.0.0"
    }

    input {
        File bam
        File? genome_fasta
        File? transcriptome_fasta
        File? genome_fasta_gz
        File? transcriptome_fasta_gz
        File? annotation_gtf
        File? annotation_gtf_gz
        Int cpu
        Int memory_gb
        String disk
    }

    call reference.maybe_decompress as genome_reference {
        input:
            input_plain=genome_fasta,
            input_gz=genome_fasta_gz,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }

    call reference.maybe_decompress as transcriptome_reference {
        input:
            input_plain=transcriptome_fasta,
            input_gz=transcriptome_fasta_gz,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }

    call reference.maybe_decompress as annotation {
        input:
            input_plain=annotation_gtf,
            input_gz=annotation_gtf_gz,
            cpu=cpu,
            memory_gb=memory_gb,
            disk=disk,
    }

    call makepbam {
        input:
            bam=bam,
            genome_fasta=genome_reference.out,
            transcriptome_fasta=transcriptome_reference.out,
            annotation_gtf=annotation.out,
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
