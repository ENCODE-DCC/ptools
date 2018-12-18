#### Gamze Gursoy & Molly E. Green, 2018#####

#requires
# python3 (required for compression algorithm to work)
# samtools
# CreateDiff.py (included in the package)
# compress.py (included in the package)


#user arguments
# (1) read length
# (2) paired end or single end squencing (PE, SE)
# (3) bam file
# (4) name of the temporary file
# (5) type of cleaning. option: all, mismatch, indel, split
# example: sh bam2pbam.sh 100 PE file.bam tmp all

#input the read length in the original BAM file
rL=$1

#mdscore will be equal to readlength as well
md=$rL

#alignment score is 2 times rL for paired-end, 1 time rL for single end
if [ $2 == 'PE' ]
then
	as=$(($rL*2))
fi

if [ $2 == 'SE' ]
then
        as=$rL
fi

#name and location of input bam
input=$3

#name of the tmp folder for tmp files
temp=$4

#set of q you want to manupilate
#options: mismatches, indels, split reads, all
if [ $5 == 'mismatch' ]
then
	q='/X/'
fi

if [ $5 == 'indel' ]
then
        q='/I|\D/'
fi

if [ $5 == 'split' ]
then
        q='/S|\H/'
fi

if [ $5 == 'all' ]
then
        q='/S|\H|\I|\D|\X/'
fi

#create the temp directory
mkdir $temp

#location of samtools
loc=samtools

#number of columns in the bam file
col="$($loc view $input | awk -F'\t' '{print NF; exit}')"
  
#find out if AS is printed
ASprint=$(($col + 10));
$loc view $input | awk -F'\t' '{print $0; exit}' > line.txt
for ((i=1; i<=$col; i++))
do
	t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
	if [ $t == 'AS' ]
	then
		ASprint=$i
	fi
done

#find out if MD is printed
MDprint=$(($col + 10));
for ((i=1; i<=$col; i++))
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [ $t == 'MD' ]
        then
                MDprint=$i
        fi
done


echo "Creating the diff file"
$loc view $input | python createDiff.py > $temp/temp.diff

#compress the .diff file
echo "Compressing the diff file"
python compress.py $temp/temp.diff $input\.diff

#remove the temporary uncompressed file
rm $temp/temp.diff

echo "Creating the pbam file"
#split the bam file as intronic and nonintronic bam
$loc view -h $input | awk '$0 ~ /^@/ || $6 ~ /N/' | samtools view -bS -> $temp\/$input\.intronic.bam
$loc view -h $input | awk '$0 ~ /^@/ || $6 !~ /N/' | samtools view -bS - > $temp\/$input\.nonintronic.bam

#get the header
$loc view -H $input > $temp/header.txt

#get the number of the columns
ntabs="$(samtools view $input | awk '{print NF;exit}')"
n=$(($ntabs-1))

#create p-bam from nonintronic
$loc view $temp\/$input\.nonintronic.bam | awk -v var="$ASprint" -v var2="$ntabs" -v var3="$n" -v var4="$MDprint" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'";  $10="*"; $11="*"; if ($6 !~ '"$q"') {{for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}} else {$6="'"$rL"'M"; {for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}}}' > $temp/preads_nonintronic.txt

#separate intronic reads
$loc view $temp\/$input\.intronic.bam | awk -v var="$ASprint"  -v var2="$ntabs" -v var3="$n" -v var4="$MDprint" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'";  $10="*"; $11="*"; if ($6 !~ '"$q"') {{for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}}}' > $temp/intronic1.txt 
$loc view $temp\/$input\.intronic.bam | awk -v var="$q" '{if ($6 ~ var) {print $0}}' > $temp/intronic2.txt

#create p-bam from intronic
cat $temp/intronic2.txt | awk '{print $6}' | awk -F'[N]' '{print $1}' | awk -F'[MDSXIH]' '{print $NF}' > $temp/lengthOFintron.txt
cat $temp/intronic2.txt | awk '{print $6}' | awk -F'[N]' '{print $1}' | awk -F'[N]' '{print $1}' | awk -F'[M]' '{print $1}' | awk -F'[SXIDH]' '{print $NF}' > $temp/lengthOFfirstM.txt
paste $temp/lengthOFfirstM.txt $temp/lengthOFintron.txt > $temp/MN.txt
awk -v rl="$rL" '{print $1"M"$2"N"rl-$1"M"}' $temp/MN.txt > $temp/MNM.txt
t=$(($ASprint+1))
m=$(($MDprint+1))
paste ./$temp/MNM.txt $temp/intronic2.txt | awk -v var="$t" -v var2=$ntabs -v var3="$n" -v var4="$m" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $11="*"; $12="*"; {for (i=2; i<=6; i++) printf "%s\t", $i}; {printf $1"\t"}; {for (i=8; i<=var2; i++) printf "%s\t",$i} {printf "%s\n",$i}}' > $temp/intronicreads.txt
cat $temp/header.txt $temp/intronic1.txt $temp/intronicreads.txt $temp/preads_nonintronic.txt > $temp/all.txt
awk '{print $0}' $temp/all.txt | samtools view -h -bS - > $temp/tmp.p.bam

#sort the pbam file
echo "Sorting the pbam file"
$loc sort $temp/tmp.p.bam > $input\.$5\.p.bam

#remove temporary folder
rm -rf $temp





