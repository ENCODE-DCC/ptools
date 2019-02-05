#### Gamze Gursoy 2018#####

#set defaults"
param1="all"
param2="BAM"
param3="n"
param4="n"
param5="n"

while [ -n "$1" ]; do # while loop starts
    case "$1" in
    -q) param1="$2"  #operation
        if [ $param1 == "file" ]
        then
                param12="$3"
                echo "file name passed, with value $param12"
        	shift
	fi
        echo "-q option passed, with value $param1"
        shift
        ;; 
    -ft)
        param2=$2 #file type
        echo "-ft option passed, with value $param2"
        shift
        ;;
    -r) 
        param3=$2 #ref file
        echo "-r option passed, with value $param3"
        shift
        ;;
    -in)
        param4=$2 #input file
        echo "-in option passed, with value $param4"
        shift
        ;;
    -rl)
        param5=$2 #read lenght
        echo "-rl option passed, with value $param5"
        shift
        ;;
    -h)
        echo "-q for operation <file/mis/indel/split/all>, default=all, if file then followed by the file name
format of the file Chr:loc-loc
-ft for output file type <BAM/SAM/CRAM>, default=BAM
-r  reference file in .fasta format, mandatory
-in name of the input file, mandatory
-rl read length, default=learned from the file
samtools, picard and python3 should be in the path"
	;;
      *) echo "Option $1 not recognized" ;;
    esac
    shift
done

if [ $param3 == "n" ]
then
	echo "please input a reference file with the option -r, type radioactive.sh -h for options"
	exit
fi

if [ $param4 == "n" ]
then
        echo "please input a inout file with the option -in, type radioactive.sh -h for options"
	exit
fi

if [ $param5 == "n" ] && [ $param4 != "n" ]
then
	param5=($(samtools view $param4 | awk '{print length($10)}'))
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
samtools view -H $param4 > $WORK_DIR/header.txt

#set reference file
reffa=$param3

#set read lentgh and tags
rL=$param5
md=$rL
as=$(($rL*2))

#set operation
if [ $param1 == "n" ] || [ $param1 == "all" ]
then
	q='/S|\H|\I|\D|\X/'
fi
if [ $param1 == "mis" ]
then
	q='X'
fi
if [ $param1 == "indel" ]
then
	q='\I|\D'
fi
if [ $param1 == "split" ]
then
	q='\S|H'
fi
if [ $param1 == "file" ]
then
	file=$param12
	q='/S|\H|\I|\D|\X/'
fi
	
#get the number of the columns
ntabs="$(samtools view $param4 | awk '{print NF;exit}')"
n=$(($ntabs-1))

echo "generating radioactive and nonradioactive part of the bam file"

if [ $param1 == "file" ]
then
	#module load Python
	samtools index $param4
	awk  '{ printf( "%s ", $1 ); } END { printf( "\n" ); }' $file > $WORK_DIR/tmp
	samtools view -h $param4 $(awk -F[.] '{print $1}' $WORK_DIR/tmp) | samtools view -h -bS -  > $WORK_DIR/tmp.bam
	samtools view $WORK_DIR/tmp.bam | python getSeq.py $reffa $WORK_DIR/header.txt $rL > $WORK_DIR/radio.txt
	awk '!seen[$0]++' $WORK_DIR/radio.txt | samtools view -h -bS - > $WORK_DIR/Radio.bam
	rm $WORK_DIR/radio.txt
	rm $WORK_DIR/tmp.bam
	rm $WORK_DIR/tmp
	samtools view $WORK_DIR/Radio.bam | awk '{print $1}' > $WORK_DIR/RadioReadList.txt
	len=($(wc -l < $WORK_DIR/RadioReadList.txt))
	if [ $len -gt 0 ]
	then
        	java -jar picard.jar FilterSamReads I=$param4 O=$WORK_DIR/nonRadio.bam READ_LIST_FILE=$WORK_DIR/RadioReadList.txt FILTER=excludeReadList
        	rm $WORK_DIR/RadioReadList.txt
	else
		samtools view -h -b -S $param4 > $WORK_DIR/nonRadio.bam
	fi
fi

if [ $param1 != "file" ]
then
	samtools view $param4 | awk '{if (($3 >= 1 && $3 <= 22) || $3=="X" || $3=="Y") print $0}' | python getSeq.py $reffa $WORK_DIR/header.txt $rL | samtools view -h -bS - > $WORK_DIR/Radio.bam
fi

input=$WORK_DIR/Radio.bam
loc=samtools
col="$($loc view $input | awk -F'\t' '{print NF; exit}')"


#find out if AS is printed
ASprint=$(($col + 10));
$loc view $input | awk -F'\t' '{print $0; exit}' > line.txt
for i in `seq 1 $col`;
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [ $t == 'AS' ]
        then
                ASprint=$i
        fi
done

#find out if MD is printed
MDprint=$(($col + 10));
for i in `seq 1 $col`;
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [ $t == 'MD' ]
        then
                MDprint=$i
        fi
done

#find out if NM is printed
NMprint=$(($col + 10));
for i in `seq 1 $col`;
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [ $t == 'NM' ] || [ $t == 'nM' ]
        then
                NMprint=$i
        fi
done


echo "Creating the diff file"
#diff from the radio
$loc view $input | python createDiff.py > $WORK_DIR/radio.diff
if [ ! -f $WORK_DIR/nonRadio.bam ]; then
	cp $WORK_DIR/radio.diff $WORK_DIR/temp.diff
else
	samtools view $WORK_DIR/nonRadio.bam | python createDiff.py > $WORK_DIR/nonradio.diff
	cat $WORK_DIR/radio.diff $WORK_DIR/nonradio.diff > $WORK_DIR/temp.diff
fi

#compress the .diff file
echo "Compressing the diff file"
python compress.py $WORK_DIR/temp.diff $param4\.diff

#remove the temporary uncompressed file
rm $WORK_DIR/temp.diff
rm $WORK_DIR/radio.diff
if [ -f $WORK_DIR/nonradio.diff ]
then
	rm $WORK_DIR/nonradio.diff
fi


echo "Creating the pbam file"
#split the bam file as intronic and nonintronic bam
$loc view -h $input | awk '$0 ~ /^@/ || $6 ~ /N/' | samtools view -bS - > $WORK_DIR/intronic.bam
$loc view -h $input | awk '$0 ~ /^@/ || $6 !~ /N/' | samtools view -bS - > $WORK_DIR/nonintronic.bam


#create p-bam from nonintronic
$loc view $WORK_DIR/nonintronic.bam | awk -v var="$ASprint" -v var2="$ntabs" -v var3="$n" -v var4="$MDprint" -v var5="$NMprint" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $var5="NM:i:0";if ($6 !~ '"$q"') {{for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}} else {$6="'"$rL"'M"; {for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}}}' > $WORK_DIR/preads_nonintronic.txt

#separate intronic reads
$loc view $WORK_DIR/intronic.bam | awk -v var="$ASprint"  -v var2="$ntabs" -v var3="$n" -v var4="$MDprint" -v var5="$NMprint" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $var5="NM:i:0";if ($6 !~ '"$q"') {{for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}}}' > $WORK_DIR/intronic1.txt
$loc view $WORK_DIR/intronic.bam | awk -v var="$q" '{if ($6 ~ var) {print $0}}' > $WORK_DIR/intronic2.txt

#create p-bam from intronic
cat $WORK_DIR/intronic2.txt | awk '{print $6}' | awk -F'[N]' '{print $1}' | awk -F'[MDSXIH]' '{print $NF}' > $WORK_DIR/lengthOFintron.txt
cat $WORK_DIR/intronic2.txt | awk '{print $6}' | awk -F'[N]' '{print $1}' | awk -F'[N]' '{print $1}' | awk -F'[M]' '{print $1}' | awk -F'[SXIDH]' '{print $NF}' > $WORK_DIR/lengthOFfirstM.txt
paste $WORK_DIR/lengthOFfirstM.txt $WORK_DIR/lengthOFintron.txt > $WORK_DIR/MN.txt
awk -v rl="$rL" '{print $1"M"$2"N"rl-$1"M"}' $WORK_DIR/MN.txt > $WORK_DIR/MNM.txt
t=$(($ASprint+1))
m=$(($MDprint+1))
paste $WORK_DIR/MNM.txt $WORK_DIR/intronic2.txt | awk -v var="$t" -v var2=$ntabs -v var3="$n" -v var4="$m" -v var5="$NMprint" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $var5="NM:i:0";{for (i=2; i<=6; i++) printf "%s\t", $i}; {printf $1"\t"}; {for (i=8; i<=var2; i++) printf "%s\t",$i} {printf "%s\n",$i}}' > $WORK_DIR/intronicreads.txt

cat $WORK_DIR/header.txt $WORK_DIR/intronic1.txt $WORK_DIR/intronicreads.txt $WORK_DIR/preads_nonintronic.txt > $WORK_DIR/all.txt
awk '{print $0}' $WORK_DIR/all.txt | samtools view -h -bS - > $WORK_DIR/tmp.p.bam

if [ -f $WORK_DIR/nonRadio.bam ]
then
	samtools merge $param4.p.bam $WORK_DIR/tmp.p.bam nonRadio.bam
fi

if [ ! -f $WORK_DIR/nonRadio.bam ]
then
        samtools view -h -b -S $WORK_DIR/tmp.p.bam > $param4.p.bam
fi

if [ $param2 == "CRAM" ] || [ $param2 == "cram" ]
then
	v2=$reffa
	echo "ref file is $v2"
	samtools view -T $v2 -C -o $param4.p.cram $param4.p.bam
	rm $param4.p.bam
	echo "$param4.p.cram is created"
elif [ $param2 == "SAM" ] || [ $param2 == "sam" ]
then
	samtools view -h $param4.p.bam > $param4.p.sam
	rm $param4.p.bam
        echo "$param4.p.sam is created"
else
	echo "$param4.p.bam is created"
fi


rm -rf $WORK_DIR
