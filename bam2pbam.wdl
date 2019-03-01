# ENCODE DCC & DAC pTools pipeline
# Maintainer: Gamze Gursoy & Otto Jolanki


workflow bam2pbam{
	#inputs
	Int? read_length
	String? operation
	String? cleanup_file
	String? output_format
	String input_file
	String ref_file


	call bam2pbam_opt0{ input:
		input_file = input_file,
                ref_file = ref_file,
        }
}

	task bam2pbam_opt0{
		Int? read_length
                String? operation
                String? cleanup_file
                String? output_format
   		String input_file
        	String ref_file

		command{
			bam2pbam.sh ${"-rl " + read_length} ${"-q " + operation} ${cleanup_file} ${"-ft " + output_format} -in ${input_file} -r ${ref_file}
		}
	} 
