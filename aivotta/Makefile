
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

CC = tcecc
TCEFLAGS += -a arch/basic.adf -k input_data,l0_weights,output_data
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
	ttasim -a arch/basic.adf -p main.tpef -e "\
	load_data /a data input_data ../data/input/5x5.bin;\
	load_data /a data l0_weights ../data/weights/conv0.bin;\
	load_data /a data l1_weights ../data/weights/conv1.bin;\
	run; x /a data /u w /n 6400 /f ../data/output/conv1.bin output_data; quit;"

clean:
	$(RM) $(OBJ)