# Recursive wildcard function. E.g. $(call rwildcard, src/, *.c *.h)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
# Executable name
EXE = main.tpef
ADF = new_fpga.adf
IDF = impl_new.idf
# Directories
PROGE = proge-output
SRC_DIR = src
OBJ_DIR = obj
INCL_DIR = $(sort $(dir $(wildcard include/*/)))

SRC = $(call rwildcard, $(SRC_DIR), *.c *.h)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
OBJ2 = $(foreach f,$(OBJ),$(f).bc)

CC = tcecc
TCEFLAGS += -a $(ADF) --bubblefish2-scheduler#--bottom-up-scheduler#--emit-llvm #--unroll-threshold=500 #--dump-ddgs-dot #--emit-llvm #--init-sp=1024 
CPPFLAGS += $(foreach dir,$(INCL_DIR),-I$(dir))# -I is a preprocessor flag, not a compiler flag
CFLAGS += -O3 -Wall --std=c11 
LDFLAGS += # -L is a linker flag
LDLIBS += # Left empty if no libs are needed

.PHONY: all clean compare simulate proc bits

all: $(EXE)

$(EXE): $(OBJ)
	$(CC) $(TCEFLAGS) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(TCEFLAGS) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

compare:
	python3 ../compare.py

simulate:
	ttasim -a $(ADF) -p $(EXE) -e "\
	load_data 0x0 mmap.bin;\
	load_data 0x23000000 ../data/ref/48x32/act0.bin;\
	load_data 0x24000000 ../data/weights/conv1.bin;\
	load_data 0x26000000 ../data/thresholds/act1.bin;\
	run;\
	puts [info proc cycles];\
	x /u w /n 12288 /f ../data/output/act1.bin 0x27000000;\
	"
#	x /u w /n 196608 /f ../data/output/conv1.bin 0x25000000;\

clean:
	$(RM) $(OBJ) $(OBJ2) $(EXE)

proc:
	rm -rf $(PROGE)
	generateprocessor --sync-reset -c 100000000 -d onchip -f onchip -e tta_core -i $(IDF) -g AlmaIFIntegrator -o $(PROGE) -p $(EXE) $(ADF)
	generatebits -e tta_core -d -w 4 -p $(EXE) -x $(PROGE) $(ADF)

bits:
	generatebits -e tta_core -d -w 4 -p $(EXE) -x TMPTMP $(ADF)