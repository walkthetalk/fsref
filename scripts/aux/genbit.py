import sys
import struct

def main():
	if len(sys.argv) < 2:
		print "usage: genbit.py infile outfile"
		return
	else:
		infile = open(sys.argv[1], 'rb')
		outfile = open(sys.argv[2], 'wb')

		inbuf = infile.read()
		outbuf = ""
		for i in range(0, len(inbuf), 4):
			x = struct.unpack("<i", inbuf[i:i+4])[0]
			outbuf += struct.pack(">i", x)
		outfile.write(outbuf)
		return

if __name__ == "__main__":
    main()
