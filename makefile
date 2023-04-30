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
DEPS = $(OBJ:%.o=%.d)

#package manager
ARCHIVE=
INCLUDES=
include $(wildcard $(PKG_DIR)/*.mk)
LDFLAG+= $(ARCHIVE)
CFLAGS+= $(INCLUDES:%=-I%)

### TEST
ifneq ($(TEST_DIR),)

TEST_SRC=$(wildcard $(TEST_DIR)/*.c)
TEST_SRCPP=$(wildcard $(TEST_DIR)/*.cpp)
TEST_OBJ=$(TEST_SRC:$(TEST_DIR)/%.c=$(BUILD_DIR)/%.test.c.o) $(TEST_SRCPP:$(TEST_DIR)/%.cpp=$(BUILD_DIR)/%.test.cpp.o)
TEST_EXE=$(EXE).test

TEST_ARCHIVE=
TEST_INCLUDES=
include $(wildcard $(PKG_DIR)/*.mk_test)
TEST_CFLAGS+= $(TEST_INCLUDES:%=-I%)
TEST_LDFLAG+= $(TEST_ARCHIVE)

endif

.PHONY: all
all: mkdir $(EXE) $(RES_OUT)

.PHONY: mkdir
mkdir:
	@mkdir -p $(BUILD_DIR)
ifneq ($(RES_DIR),)
	@mkdir -p $(BUILD_DIR)/$(RES_DIR)
	@mkdir -p $(RES_CHILD_DIR:$(RES_DIR)/%=$(BUILD_DIR)/$(RES_DIR)/%)
endif

.PHONY: run
run: all
	$(info Running $(EXE))
	@./$(EXE)

.PHONY: test
test: CFLAGS+= -DTEST -Dmain=_not_main
test: clean mkdir $(TEST_EXE)
	$(info Running $(TEST_EXE))
ifneq ($(TEST_DIR),)
	@./$(TEST_EXE)
else
    $(info No tests found)
endif

.PHONY: clean
clean:
	$(info Cleaning)
	@\rm -rf $(BUILD_DIR) compile_commands.json

.PHONY: lsp
lsp: clean
	$(info Updating compile_commands.json)
	@bear -- $(MAKE) all
ifneq ($(TEST_DIR),)
	@bear --append -- $(MAKE) $(TEST_EXE)
endif

.PHONY: package
package: $(PKG_FILE)
	$(info Installing Packages)
	@./pm.sh $(PKG_DIR) $(PKG_FILE)

.PHONY: distclean
distclean:
	$(info Cleaning)
	@\rm -rf $(BUILD_DIR) $(PKG_FILE) compile_commands.json

$(EXE): $(OBJ)
	$(info Linking $@)
	@$(CPP) $(CFLAGS) -o $@ $^ $(LDFLAG)

$(BUILD_DIR)/%.cpp.o: $(SRC_DIR)/%.cpp $(BUILD_DIR)/%.cpp.d
	$(info Compiling $<)
	@$(CPP) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c $(BUILD_DIR)/%.c.d
	$(info Compiling $<)
	@$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.cpp.d: $(SRC_DIR)/%.cpp
	$(info Generating dependencies for $<)
	@$(CPP) $(CFLAGS) -MM -MT $(@:%.d=%.o) $< > $@

$(BUILD_DIR)/%.c.d: $(SRC_DIR)/%.c
	$(info Generating dependencies for $<)
	@$(CC) $(CFLAGS) -MM -MT $(@:%.d=%.o) $< > $@

$(BUILD_DIR)/$(RES_DIR)/%: $(RES_DIR)/%
	$(info Copying $< to $@)
	@cp $< $@

########
##TEST##
########

$(TEST_EXE): $(TEST_OBJ) $(OBJ)
	$(info Linking $@)
	@$(CPP) $(CFLAGS) -o $@ $^ $(LDFLAG) $(TEST_LDFLAG)

$(BUILD_DIR)/%.test.cpp.o: $(TEST_DIR)/%.cpp $(BUILD_DIR)/%.test.cpp.d
	$(info Compiling $<)
	@$(CPP) $(CFLAGS) $(TEST_CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.test.c.o: $(TEST_DIR)/%.c $(BUILD_DIR)/%.test.c.d
	$(info Compiling $<)
	@$(CC) $(CFLAGS) $(TEST_CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.test.cpp.d: $(TEST_DIR)/%.cpp
	$(info Generating dependencies for $<)
	@$(CPP) $(CFLAGS) -MM -MT $(@:%.d=%.o) $< > $@

$(BUILD_DIR)/%.test.c.d: $(TEST_DIR)/%.c
	$(info Generating dependencies for $<)
	@$(CC) $(CFLAGS) -MM -MT $(@:%.d=%.o) $< > $@

BUILD_EXISTS := $(shell test -e $(BUILD_DIR) && echo 1 || echo 0)
ifeq ($(BUILD_EXISTS), 1)
-include $(DEPS)
endif
