# Recursive wildcard function. E.g. $(call rwildcard, src/, *.c *.h)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
# Executable name
EXE = main.tpef
ADF = small.adf
IDF = impl_small.idf
# Directories
PROGE = proge-output
SRC_DIR = src
OBJ_DIR = obj
INCL_DIR = $(sort $(dir $(wildcard include/*/)))

SRC = $(call rwildcard, $(SRC_DIR), *.c *.h)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
OBJ2 = $(foreach f,$(OBJ),$(f).bc)

CC = tcecc
TCEFLAGS += -a $(ADF)
CPPFLAGS += $(foreach dir,$(INCL_DIR),-I$(dir))# -I is a preprocessor flag, not a compiler flag
CFLAGS += -O0 -Wall --std=c11 
LDFLAGS += # -L is a linker flag
LDLIBS += # Left empty if no libs are needed

.PHONY: all clean compare simulate proc

all: $(EXE)

$(EXE): $(OBJ)
	$(CC) $(TCEFLAGS) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(TCEFLAGS) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

compare:
	python3 ../compare.py

simulate:
	ttasim -a $(ADF) -p $(EXE) -e "\
	load_data /a data 0x60000000 ../data/input/5x5.bin;\
	load_data /a data 0x60000034 ../data/weights/conv0.bin;\
	run;\
	x /a data /n 6400 /u w /f ../data/output/conv0.bin 0x600004b4;\
	x /a data /n 200 /u w /f ../data/output/act0.bin 0x60001db4;\
	puts [info proc cycles];\
	quit;"

clean:
	$(RM) $(OBJ) $(OBJ2) $(EXE)

proc:
	rm -rf $(PROGE)
	generateprocessor --sync-reset -c 50000000 -d onchip -f onchip -e tta_core -i $(IDF) -g AlmaIFIntegrator -o $(PROGE) -p $(EXE) $(ADF)
	generatebits -e tta_core -d -w 4 -p $(EXE) -x $(PROGE) $(ADF)