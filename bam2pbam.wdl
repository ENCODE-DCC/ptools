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
                String cmdLineRL = if isDefined(read_length) then "-rl ${read_length}" else ""
                String cmdLineOP = if isDefined(operation) then "-q ${operation}" else ""
                String cmdLineCF = if isDefined(cleanup_file) then "${cleanup_file}" else ""
                String cmdLineOF = if isDefined(output_format) then "-ft ${output_format}" else ""
    		String input_file
        	String ref_file

		command{
			sh $(which bam2pbam.sh) ${cmdLineRL} ${cmdLineOP} ${cmdLineCF} ${cmdLineOF} -in ${input_file} -r ${ref_file}
		}
	} 
