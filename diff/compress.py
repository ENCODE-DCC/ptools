"""
comp_decomp.py

Compression on a specific file, using sys (in: raw file, out: Mycompdata.txt)

Decompression of compressed file to original file (in: Mycompdata.txt, out: Mydecompdata.txt)

"""

import zlib, sys, time, base64

# Compression of raw file
rawfile = sys.argv[1]
outfile = sys.argv[2]
fp = open(rawfile, "rb")
text = fp.read()

print("Raw size:", sys.getsizeof(text))

compressed = zlib.compress(text, 9)
print("compressed size:", sys.getsizeof(compressed))

savecomp = open(outfile, "wb")
savecomp.write(compressed)
savecomp.close()
