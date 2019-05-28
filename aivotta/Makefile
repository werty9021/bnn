
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
TCEFLAGS += --swfp -a arch/basic.adf -k input_data,l0_weights
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
	pipenv run python ../compare.py

simulate:
	ttasim -a arch/basic.adf -p main.tpef -e "\
	load_data /a data input_data ../data/input.bin;\
	load_data /a data l0_weights ../data/weights/conv0.bin;\
	run; x /a data /u w /n 20 /f ../data/output/out.bin input_data; quit;"

clean:
	$(RM) $(OBJ)