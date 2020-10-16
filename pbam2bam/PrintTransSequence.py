# PrintSequence.py Function for Gamze
# Readme.txt
# NOTE: You'll need to run this on a node, i.e. an interactive node, and you'll need to request more memory
# To request a node with 16gigs of memory, use:

# $ srun --pty -p interactive --mem=16g bash

# This script contains three portions. The first is an initialization step, which will read the reference genome ('genome.fa'). The second portion is 'query'--a function which will take the chromosome number, the position number on that chromosome, and the number of basepairs (len), and will output the sequence (in string format). The third portion, numbps (short for "number [of] basepairs"), will return the number of basepairs for an inputted chromosome. Input for chromosome must be as "chr*", where * may be any natural number.

# Example usage:
#
#
#
# $ module load Python
# $ python -i PrintSequence.py
# (the -i tells bash to stay in python after the file has loaded)
# (Allow it to load)

# To print out the sequence of interest, type

# tbl.query(chromosome number, position number, number of basepairs) i.e. for chromosome 1, position 100000, and print 100 basepairs, the sytax would be tbl.query('chr1', 100000, 100)

# To print out the number of basepairs for a chromosome of interest, i.e. chromosome 1, type
# tbl.numbps('chr1')

from Bio import SeqIO

# This is a nice set of tools that are open-source, and freely available. This will read a fasta file and allow us to use the file flexibly.


# This script is using "object-oriented programming". We will build an object that we can load (initialize) once, and then pull from.
class Lookup:
    def __init__(self, f):
        self.chroms = {}  # creating a dictionary within the class
        for record in SeqIO.parse(f, "fasta"):  # From http://biopython.org/wiki/SeqIO
            a = str(record.id)
            newid = a.split("|")[0]
            self.chroms[
                newid
            ] = (
                record.seq
            )  # Filling the dictionary with chromosomes as keys, and the sequence as the value.

    #            print("read %s" % record.id) #Lets us know when each piece of the object is done loading

    # This query function will automatically fill in the 'self' argument, but will then accept the chromosome number as 'chr$c'--where $c is a natural number, pos is the position number, and len is the number of basepairs

    def query(self, chrom, pos, len):
        if chrom in self.chroms:
            return str(self.chroms[chrom][pos : pos + len])
        else:
            return 0  # str returns a string version of our output. Our output is the object we created, the dictionary using key chrom, and indexed from our starting position to our position plus number of basepairs.

    # This numbps function will accept a chromosome number, as 'chr1' for example.

    def numbps(self, chrom):
        return len(
            self.chroms[chrom]
        )  # This returns the length (count) of the basepairs of the value assigned to the chroms dictionary under the chrom key.


# This ensures that when we run the program that we assign tbl to the class and input our reference genome (genome.fa) as our file (f in __init__(self, f)).
if __name__ == "__main__":
    tbl = Lookup("../gencode.v19.pc_transcripts.fa")

    print("Initialization complete.")
