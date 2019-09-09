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
TCEFLAGS += -a new_with_stdout.adf
CPPFLAGS += $(foreach dir,$(INCL_DIR),-I$(dir))# -I is a preprocessor flag, not a compiler flag
CFLAGS += -O3 --std=c11 
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
	ttasim -a new_with_stdout.adf -p main.tpef -e "\
	load_data /a parameters input_data ../data/input/5x5.bin;\
	load_data /a parameters l0_weights ../data/weights/conv0.bin;\
	load_data /a parameters conv1_weights ../data/weights/conv1.bin;\
	load_data /a parameters act1_thresholds ../data/thresholds/act1.bin;\
	load_data /a parameters conv2_weights ../data/weights/conv2.bin;\
	load_data /a parameters act2_thresholds ../data/thresholds/act2.bin;\
	load_data /a parameters conv3_weights ../data/weights/conv3.bin;\
	load_data /a parameters act3_thresholds ../data/thresholds/act3.bin;\
	load_data /a parameters conv4_weights ../data/weights/conv4.bin;\
	load_data /a parameters act4_thresholds ../data/thresholds/act4.bin;\
	load_data /a parameters conv5_weights ../data/weights/conv5.bin;\
	load_data /a parameters act5_thresholds ../data/thresholds/act5.bin;\
	load_data /a parameters conv6_weights ../data/weights/conv6.bin;\
	load_data /a parameters act6_thresholds ../data/thresholds/act6.bin;\
	load_data /a parameters conv7_weights ../data/weights/conv7.bin;\
	load_data /a parameters act7_thresholds ../data/thresholds/act7.bin;\
	load_data /a parameters conv8_weights ../data/weights/conv8.bin;\
	load_data /a parameters act8_thresholds ../data/thresholds/act8.bin;\
	load_data /a parameters conv9_weights ../data/weights/conv9.bin;\
	load_data /a parameters act9_thresholds ../data/thresholds/act9.bin;\
	load_data /a parameters conv10_weights ../data/weights/conv10.bin;\
	load_data /a parameters act10_thresholds ../data/thresholds/act10.bin;\
	load_data /a parameters conv11_weights ../data/weights/conv11.bin;\
	load_data /a parameters act11_thresholds ../data/thresholds/act11.bin;\
	load_data /a parameters conv12_weights ../data/weights/conv12.bin;\
	load_data /a parameters act12_thresholds ../data/thresholds/act12.bin;\
	load_data /a parameters conv13_weights ../data/weights/conv13.bin;\
	load_data /a parameters act13_thresholds ../data/thresholds/act13.bin;\
	load_data /a parameters conv14_weights ../data/weights/conv14.bin;\
	load_data /a parameters act14_thresholds ../data/thresholds/act14.bin;\
	load_data /a parameters conv15_weights ../data/weights/conv15.bin;\
	load_data /a parameters act15a_thresholds ../data/thresholds/act15_a.bin;\
	load_data /a parameters act15b_thresholds ../data/thresholds/act15_b.bin;\
	load_data /a parameters conv16_weights ../data/weights/conv16.bin;\
	run;\
	x /a inputdata /u w /n 393216 /f ../data/output/act15.bin act15_output;\
	x /a parameters /u w /n 6144 /f ../data/output/conv16.bin conv16_output;\
	puts [info proc cycles];"

clean:
	$(RM) $(OBJ) $(OBJ2) $(EXE)