'''
comp_decomp.py

Compression on a specific file, using sys (in: raw file, out: Mycompdata.txt)

Decompression of compressed file to original file (in: Mycompdata.txt, out: Mydecompdata.txt)

'''

import sys
import gzip
import shutil
import os

# Compression of raw file
rawfile = sys.argv[1]
outfile = sys.argv[2]
with open(rawfile, 'rb') as file_in:
    with gzip.open(outfile, 'wb') as file_out:
        shutil.copyfileobj(file_in, file_out)

print('Raw size:', os.path.getsize(rawfile))
print('compressed size:', os.path.getsize(outfile))
