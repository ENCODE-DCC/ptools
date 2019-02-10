####### Gamze Gursoy  2019 ########
#input arguments
# (1) pbam file
# (2) reference genome used to align the reads, which one is used can be found un the pbam header
# (3) path to .diff file
# (4) name of the diff file
# (5) temporary folder to decompress the diff file
# (6) read length

# Please note that current version can only create bam files for reads mapped to the sequences defined in the reference genome such as autosomal chromosomes, chr x and y and some other contigs.
# However if you used transcriptome annotation while mapoping to reference genome, some of the reads might map to transcripts (read coordinate starts with ENS). Current version cannot retrive back those reads (which are very small portion of the bam file). However we are currently developing another version of the software that takes reference transcriptome as an input as well to retrieve back those reads when we create back the original bam files.

#set defaults"
param1="n"
param2="n"
param3="./"
param4="n"
param5="n"
param6="BAM"

while [ -n "$1" ]; do # while loop starts
    case "$1" in
    -in) param1="$2"  #input pbam
       echo "-in option passed, with value $param1"
        shift
        ;;
    -r)
        param2=$2 #reference file
        echo "-r option passed, with value $param2"
        shift
        ;;
    -p)
        param3=$2 #path to diff
        echo "-p option passed, with value $param3"
        shift
        ;;
    -d)
	param4=$2 #diff file
	echo "-d option passed, with value $param4"
	shift
	;;
    -rl)
        param5=$2 #read lenght
        echo "-rl option passed, with value $param5"
        shift
        ;;
    -ft)
	param6=$2 #output type
	echo "-ft option passed, with value $param6"
	shift
	;;
    -h)
        echo "-in name of the pbam/pcram/psam file iwth full path and extension
-r reference file
-p path to the .diff file, default is the current directory
-d name of the diff file with the extension
-ft for the output file type <BAM/SAM/CRAM>, default is BAM
samtools and python3 should be in the path"
        ;;
      *) echo "Option $1 not recognized" ;;
    esac
    shift
done

if [ $param1 == "n" ]
then
        echo "please input a pbam file with the option -in, type pbam2bam.sh -h for options"
        exit
fi

if [ $param2 == "n" ]
then
        echo "please input a reference with the option -r, type pbam2bam.sh -h for options"
        exit
fi

if [ $param4 == "n" ]
then
        echo "please input a diff with the option -d, type pbam2bam.sh -h for options"
        exit
fi

if [ $param5 == "n" ] && [ $param1 != "n" ]
then
        param5=($(samtools view $param1 | awk '{print length($10)}'))
        echo "Read length is $param5"
fi

#create a temporary folder
# the directory of the script
echo "creating a temporary directory"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

#get the header
samtools view -H $param1 > $WORK_DIR/header.txt

#set reference file
reffa=$param2

#create bam file
if [ $param6 == "BAM" ] || [ $param6 == "bam" ]
then
	
	samtools view $param1 | python pbam2bam.py $reffa $param3 $param4 $WORK_DIR $WORK_DIR/header.txt $param5 | samtools view -bS - > $param1\.bam
	echo "$param1\.bam is created"
	rm -rf $WORK_DIR
fi



if [ $param6 == "SAM" ] || [ $param6 == "sam" ]
then
        samtools view $param1 | python pbam2bam.py $reffa $param3 $param4 $WORK_DIR $WORK_DIR/header.txt $param5 | samtools view  > $param1\.sam
        echo "$param1\.sam is created."
	rm -rf $WORK_DIR
fi

if [ $param6 == "CRAM" ] || [ $param6 == "cram" ]
then
        samtools view $param1 | python pbam2bam.py $reffa $param3 $param4 $WORK_DIR $WORK_DIR/header.txt $param5 | samtools view -bS - > $WORK_DIR/$param1\.bam
	v2=$reffa
        echo "ref file is $v2"
        samtools view -T $v2 -C -o $param1.cram $WORK_DIR/$param1\.bam
	echo "$param1.cram is created"        
	rm -rf $WORK_DIR
fi

