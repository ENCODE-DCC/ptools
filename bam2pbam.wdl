# ENCODE DCC & DAC pTools pipeline
# Maintainer: Gamze Gursoy & Otto Jolanki


workflow bam2pbam {
    #inputs
    Int? read_length
    String? operation
    String? cleanup_file
    String output_format="bam"
    String output_prefix
    File input_file
    File ref_file


    call bam2pbam_opt0 { input:
        input_file = input_file,
        ref_file = ref_file,
        output_prefix = output_prefix,
        output_format = output_format,
    }
}

    task bam2pbam_opt0 {
        Int? read_length
        String? operation
        String? cleanup_file
        String output_format
        File input_file
        File ref_file
        String output_prefix

        command {
            bam2pbam.sh ${"-rl " + read_length} \
                ${"-q " + operation} \
                ${cleanup_file} \
                -ft ${output_format} \
                -in ${input_file} \
                -r ${ref_file} \
                -output_prefix ${output_prefix}
        }

        output {
            File diff = glob("*.diff")[0]
            File p_file = glob(output_prefix+".p."+output_format)[0]
        }
    }
