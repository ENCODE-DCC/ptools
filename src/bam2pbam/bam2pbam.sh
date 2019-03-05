#!/bin/bash

#### Gamze Gursoy 2018#####

#module load Python



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

#get the header
samtools view -H $param4 > header.txt

#set reference file
reffa=$param3

#set read lentgh and tags
rL=$param5
md=$rL
as=$(($rL*2))

#set operation
if [[ $param1 == "n" ]] || [[ $param1 == "all" ]]
then
    q='S|H|I|D|X'
    echo $q
fi
if [[ $param1 == "mis" ]]
then
    q='X'
fi
if [[ $param1 == "indel" ]]
then
    q='I|D'
fi
if [[ $param1 == "split" ]]
then
    q='S|H'
fi
if [[ $param1 == "file" ]]
then
    file=$param12
    q='S|H|I|D|X'
fi
    
#get the number of the columns
ntabs="$(samtools view $param4 | awk '{print NF;exit}')"
n=$(($ntabs-1))

echo "generating radioactive and nonradioactive part of the bam file"

if [[ $param1 == "file" ]]
then
    #module load Python
    samtools index $param4
    awk  '{ printf( "%s ", $1 ); } END { printf( "\n" ); }' $file > tmp
    samtools view -h $param4 $(awk -F[.] '{print $1}' tmp) | samtools view -h -bS -  > tmp.bam
    samtools view tmp.bam | python getSeq.py $reffa header.txt $rL > radio.txt
    awk '!seen[$0]++' radio.txt | samtools view -h -bS - > Radio.bam
    rm radio.txt
    rm tmp.bam
    rm tmp
    samtools view Radio.bam | awk '{print $1}' > RadioReadList.txt
    len=($(wc -l < RadioReadList.txt))
    if [[ $len -gt "0" ]]
    then
            java -jar picard.jar FilterSamReads I=$param4 O=nonRadio.bam READ_LIST_FILE=RadioReadList.txt FILTER=excludeReadList
            rm RadioReadList.txt
        samtools merge both.bam nonRadio.bam Radio.bam
                samtools sort both.bam -o bothsorted.bam
                rm both.bam
    else
        samtools view -h -b -S $param4 > nonRadio.bam
        samtools merge both.bam nonRadio.bam Radio.bam
        samtools sort both.bam -o bothsorted.bam
        rm both.bam
    fi
fi

if [[ $param1 != "file" ]]
then
    samtools view $param4 | awk '{if (($3 >= 1 && $3 <= 22) || $3=="X" || $3=="Y") print $0}' | python /software/ptools/src/getSeq.py $reffa header.txt $rL | samtools view -h -bS - > Radio.bam
    samtools sort Radio.bam -o bothsorted.bam
fi

input=Radio.bam
loc=samtools
col="$($loc view $input | awk -F'\t' '{print NF; exit}')"


#find out if AS is printed
ASprint=$(($col + 10));
$loc view $input | awk -F'\t' '{print $0; exit}' > line.txt
for i in `seq 1 $col`;
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [[ $t == "AS" ]]
        then
                ASprint=$i
        fi
done

#find out if MD is printed
MDprint=$(($col + 10));
for i in `seq 1 $col`;
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [[ $t == "MD" ]]
        then
                MDprint=$i
        fi
done

#find out if NM is printed
NMprint=$(($col + 10));
for i in `seq 1 $col`;
do
        t=($(awk -v var="$i" '{print $var}' line.txt | awk -F':' '{print $1}'))
        if [[ $t == "NM" ]] || [[ $t == "nM" ]]
        then
                NMprint=$i
        fi
done

fbname=$(basename "$param4" | cut -d. -f1)

echo "Creating the diff file"
#diff from the radio
$loc view bothsorted.bam | python /software/ptools/src/createDiff.py > temp.diff

#compress the .diff file
echo "Compressing the diff file"
python /software/ptools/src/compress.py temp.diff $fbname.diff

#remove the temporary uncompressed file
rm temp.diff

echo "Creating the pbam file"
#split the bam file as intronic and nonintronic bam
$loc view -h $input | awk '$0 ~ /^@/ || $6 ~ /N/' | samtools view -bS - > intronic.bam
$loc view -h $input | awk '$0 ~ /^@/ || $6 !~ /N/' | samtools view -bS - > nonintronic.bam


#create p-bam from nonintronic
$loc view nonintronic.bam | awk -v var="$ASprint" -v var2="$ntabs" -v var3="$n" -v var4="$MDprint" -v var5="$NMprint" -v vv="$q" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $var5="NM:i:0";if ($6 !~ vv) {{for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}} else {$6="'"$rL"'M"; {for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}}}' > preads_nonintronic.txt

#separate intronic reads
$loc view intronic.bam | awk -v var="$ASprint"  -v var2="$ntabs" -v var3="$n" -v var4="$MDprint" -v var5="$NMprint" -v vv="$q" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $var5="NM:i:0";if ($6 !~ vv) {{for (i=1; i<=var3; i++) printf "%s\t", $i} {printf "%s\n", $i}}}' > intronic1.txt
$loc view intronic.bam | awk -v var="$q" '{if ($6 ~ "var") {print $0}}' > intronic2.txt

#create p-bam from intronic
cat intronic2.txt | awk '{print $6}' | awk -F'[N]' '{print $1}' | awk -F'[MDSXIH]' '{print $NF}' > lengthOFintron.txt
cat intronic2.txt | awk '{print $6}' | awk -F'[N]' '{print $1}' | awk -F'[N]' '{print $1}' | awk -F'[M]' '{print $1}' | awk -F'[SXIDH]' '{print $NF}' > lengthOFfirstM.txt
paste lengthOFfirstM.txt lengthOFintron.txt > MN.txt
awk -v rl="$rL" '{print $1"M"$2"N"rl-$1"M"}' MN.txt > MNM.txt
t=$(($ASprint+1))
m=$(($MDprint+1))
paste MNM.txt intronic2.txt | awk -v var="$t" -v var2=$ntabs -v var3="$n" -v var4="$m" -v var5="$NMprint" '{$var="AS:i:'"$as"'"; $var4="MD:Z:'"$md"'"; $var5="NM:i:0";{for (i=2; i<=6; i++) printf "%s\t", $i}; {printf $1"\t"}; {for (i=8; i<=var2; i++) printf "%s\t",$i} {printf "%s\n",$i}}' > intronicreads.txt

cat header.txt intronic1.txt intronicreads.txt preads_nonintronic.txt > all.txt
awk '{print $0}' all.txt | samtools view -h -bS - > tmp.p.bam

if [ -f nonRadio.bam ]
then
    samtools merge tmp2.p.bam tmp.p.bam nonRadio.bam
    samtools sort tmp2.p.bam -o $fbname.p.bam
fi 

if [ ! -f nonRadio.bam ]
then
        samtools view -h -b -S tmp.p.bam > tmp2.p.bam 
    samtools sort tmp2.p.bam -o $fbname.p.bam
fi

if [ $param2 == "CRAM" ] || [ $param2 == "cram" ]
then
    v2=$reffa
    echo "ref file is $v2"
    samtools view -T $v2 -C -o $param4.p.cram $fbname.p.bam
    rm $fbname.p.bam
    echo "$fbname.p.cram is created"
elif [ $param2 == "SAM" ] || [ $param2 == "sam" ]
then
    samtools view -h $fbname.p.bam > $fbname.p.sam
    rm $fbname.p.bam
        echo "$fbname.p.sam is created"
else
    echo "$fbname.p.bam is created"
fi
