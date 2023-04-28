include config.mk

ifneq ($(RES_DIR),)
RES = $(shell find $(RES_DIR) -type f)
RES_CHILD_DIR = $(shell find $(RES_DIR) -type d)
RES_OUT = $(RES:$(RES_DIR)/%=$(BUILD_DIR)/$(RES_DIR)/%)
endif
SRCPP = $(wildcard $(SRC_DIR)/*.cpp)
SRC = $(wildcard $(SRC_DIR)/*.c)
EXE = $(BUILD_DIR)/$(PROJ_NAME)
OBJ = $(SRCPP:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.cpp.o) $(SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.c.o)
LDFLAG+= $(LIBS:%=-l%)
CFLAGS+= $(INC_DIR:%=-I%) -DVERSION=\"$(VERSION)\"


#package manager
ARCHIVE=
INCLUDES=
include $(wildcard $(PKG_DIR)/*.mk)
LDFLAG+= $(ARCHIVE)
CFLAGS+= $(INCLUDES:%=-I%)

.PHONY: all clean run clean lsp package
all: mkdir $(EXE) $(RES_OUT)
mkdir:
	@mkdir -p $(BUILD_DIR)
ifneq ($(RES_DIR),)
	@mkdir -p $(BUILD_DIR)/$(RES_DIR)
	@mkdir -p $(RES_CHILD_DIR:$(RES_DIR)/%=$(BUILD_DIR)/$(RES_DIR)/%)
endif

run: all
	$(info Running $(EXE))
	@./$(EXE)

clean:
	$(info Cleaning)
	@\rm -rf $(BUILD_DIR) compile_commands.json

lsp: clean
	$(info Updating compile_commands.json)
	@bear -- $(MAKE) all

package: $(PKG_FILE)
	$(info Installing Packages)
	@./pm.sh $(PKG_DIR) $(PKG_FILE)

$(EXE): $(OBJ)
	$(info Linking $@)
	@$(CPP) $(CFLAGS) -o $@ $^ $(LDFLAG)

$(BUILD_DIR)/%.cpp.o: $(SRC_DIR)/%.cpp
	$(info Compiling $<)
	@$(CPP) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(info Compiling $<)
	@$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/$(RES_DIR)/%: $(RES_DIR)/%
	$(info Copying $< to $@)
	@cp $< $@
