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
TCEFLAGS += -a basic.adf
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
	ttasim -a basic.adf -p main.tpef -e "\
	load_data /a data input_data ../data/input/5x5.bin;\
	load_data /a inputdata l0_weights ../data/weights/conv0.bin;\
	load_data /a inputdata conv1_weights ../data/weights/conv1.bin;\
	load_data /a inputdata act1_thresholds ../data/thresholds/act1.bin;\
	load_data /a inputdata conv2_weights ../data/weights/conv2.bin;\
	load_data /a inputdata act2_thresholds ../data/thresholds/act2.bin;\
	load_data /a inputdata conv3_weights ../data/weights/conv3.bin;\
	load_data /a inputdata act3_thresholds ../data/thresholds/act3.bin;\
	load_data /a inputdata conv4_weights ../data/weights/conv4.bin;\
	load_data /a inputdata act4_thresholds ../data/thresholds/act4.bin;\
	load_data /a inputdata conv5_weights ../data/weights/conv5.bin;\
	load_data /a inputdata act5_thresholds ../data/thresholds/act5.bin;\
	load_data /a inputdata conv6_weights ../data/weights/conv6.bin;\
	load_data /a inputdata act6_thresholds ../data/thresholds/act6.bin;\
	load_data /a inputdata conv7_weights ../data/weights/conv7.bin;\
	load_data /a inputdata act7_thresholds ../data/thresholds/act7.bin;\
	load_data /a inputdata conv8_weights ../data/weights/conv8.bin;\
	load_data /a inputdata act8_thresholds ../data/thresholds/act8.bin;\
	load_data /a inputdata conv9_weights ../data/weights/conv9.bin;\
	load_data /a inputdata act9_thresholds ../data/thresholds/act9.bin;\
	load_data /a inputdata conv10_weights ../data/weights/conv10.bin;\
	load_data /a inputdata act10_thresholds ../data/thresholds/act10.bin;\
	load_data /a inputdata conv11_weights ../data/weights/conv11.bin;\
	load_data /a inputdata act11_thresholds ../data/thresholds/act11.bin;\
	load_data /a inputdata conv12_weights ../data/weights/conv12.bin;\
	load_data /a inputdata act12_thresholds ../data/thresholds/act12.bin;\
	load_data /a inputdata conv13_weights ../data/weights/conv13.bin;\
	load_data /a inputdata act13_thresholds ../data/thresholds/act13.bin;\
	load_data /a inputdata conv14_weights ../data/weights/conv14.bin;\
	load_data /a inputdata act14_thresholds ../data/thresholds/act14.bin;\
	load_data /a inputdata conv15_weights ../data/weights/conv15.bin;\
	load_data /a inputdata act15a_thresholds ../data/thresholds/act15_a.bin;\
	load_data /a inputdata act15b_thresholds ../data/thresholds/act15_b.bin;\
	load_data /a inputdata conv16_weights ../data/weights/conv16.bin;\
	run;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv0.bin conv0_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act0.bin act0_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv1.bin conv1_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act1.bin act1_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv2.bin conv2_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act2.bin act2_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv3.bin conv3_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act3.bin act3_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv4.bin conv4_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act4.bin act4_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv5.bin conv5_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act5.bin act5_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv6.bin conv6_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act6.bin act6_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv7.bin conv7_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act7.bin act7_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv8.bin conv8_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act8.bin act8_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv9.bin conv9_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act9.bin act9_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv10.bin conv10_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act10.bin act10_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv11.bin conv11_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act11.bin act11_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv12.bin conv12_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act12.bin act12_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv13.bin conv13_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act13.bin act13_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv14.bin conv14_output;\
	x /a inputdata /u w /n 200 /f ../data/output/act14.bin act14_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/conv15.bin conv15_output;\
	x /a inputdata /u w /n 6400 /f ../data/output/act15.bin act15_output;\
	x /a inputdata /u w /n 100 /f ../data/output/conv16.bin conv16_output;\
	puts [info proc cycles];\
	quit;"

clean:
	$(RM) $(OBJ)