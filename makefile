### PROJECT CONFIG ###
PROJ_NAME = $(shell basename $(CURDIR))
VERSION = 0.0.1
SRC_DIR = src
BUILD_DIR = build
# RES_DIR = res
INC_DIR = src

### COMPILER CONFIG ###
CC=gcc -std=c17
CPP=g++ -std=c++17
CFLAGS= -Wall -Wextra -pedantic -O0 -g -I$(INC_DIR) -DVERSION=\"$(VERSION)\"
LIBS=  # your libs here
LDFLAG= $(LIBS:%=-l%)



###################### DO NOT EDIT BELOW THIS LINE ######################

# RES = $(wildcard $(RES_DIR)/*)
# RES_OUT = $(RES:$(RES_DIR)/%=$(BUILD_DIR)/res/%)
SRCPP = $(wildcard $(SRC_DIR)/*.cpp)
SRC = $(wildcard $(SRC_DIR)/*.c)
EXE = $(BUILD_DIR)/$(PROJ_NAME)
OBJ = $(SRCPP:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.cpp.o) $(SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.c.o)

.PHONY: all clean run clean lsp
all: mkdir $(EXE)
mkdir:
	@mkdir -p $(BUILD_DIR) $(BUILD_DIR)/res

run: all
	$(info Running $(EXE))
	@./$(EXE)

clean:
	$(info Cleaning)
	@\rm -rf $(BUILD_DIR) compile_commands.json

lsp: clean
	$(info Updating compile_commands.json)
	@bear -- $(MAKE) all

$(EXE): $(OBJ)
	$(info Linking $@)
	@$(CPP) $(CFLAGS) -o $@ $^ $(LDFLAG)

$(BUILD_DIR)/%.cpp.o: $(SRC_DIR)/%.cpp
	$(info Compiling $<)
	@$(CPP) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(info Compiling $<)
	@$(CC) $(CFLAGS) -c -o $@ $<
