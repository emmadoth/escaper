SRC = escaper
OUT = escape
WRN = -w+all
FMTN = elf64
FMTL = elf_x86_64

default:
	nasm -f $(FMTN) $(WRN) $(SRC).s
	ld -m $(FMTL) $(SRC).o -o $(OUT)
debug:
	nasm -g -f $(FMTN) $(WRN) $(SRC).s
	ld -m $(FMTL) $(SRC).o -o $(OUT)

