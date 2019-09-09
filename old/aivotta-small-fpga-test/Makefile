# Recursive wildcard function. E.g. $(call rwildcard, src/, *.c *.h)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
# Executable name
EXE = main.tpef
# Directoies
SRC_DIR = src
OBJ_DIR = obj
INCL_DIR = $(sort $(dir $(wildcard include/*/)))

SRC = $(call rwildcard, $(SRC_DIR), *.c *.h)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
OBJ2 = $(foreach f,$(OBJ),$(f).bc)

CC = tcecc
TCEFLAGS += -a small.adf
CPPFLAGS += $(foreach dir,$(INCL_DIR),-I$(dir))# -I is a preprocessor flag, not a compiler flag
CFLAGS += -O0 --std=c11 
LDFLAGS += # -L is a linker flag
LDLIBS += # Left empty if no libs are needed

.PHONY: all clean compare simulate

all: $(EXE)

$(EXE): $(OBJ)
	$(CC) $(TCEFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(TCEFLAGS) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

compare:
	python3 ../compare.py

simulate:
	ttasim -a small.adf -p main.tpef -e "\
	run;\
	puts [info proc cycles];"

clean:
	$(RM) $(OBJ) $(OBJ2) $(EXE)

proc:
	rm -rf proge-output/
	generateprocessor --sync-reset -c 50000000 -d onchip -f onchip -e tta_core -i small.idf -g AlmaIFIntegrator -o proge-output -p main.tpef small.adf
	#generatebits -e tta_core -x proge-output small.adf
	generatebits -e tta_core -d -w 4 -p main.tpef -x proge-output small.adf