MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
	
# 
# executables
#

EMCC = emcc
WEBPACK = node --max_old_space_size=8192 ./node_modules/.bin/webpack --progress
PACKAGER = node ./node_modules/.bin/electron-packager
MEMORY = 16777216

#
# emscripen flags
#

REL_FLAGS = -Os -s TOTAL_MEMORY=$(MEMORY)
DBG_FLAGS = -g -s TOTAL_MEMORY=$(MEMORY)
E_FLAGS = -v --memory-init-file 0 --closure 0

# 
# webpack debug flags
#

REL_CFG = release.config.js
DBG_CFG = debug.config.js
W_FLAGS = --verbose --display-reasons --debug --display-modules --display-error-details --colors

#
# source directories and files
#

SRC = src

MAIN = main
RNDR = rndr

MAIN_C = $(addsuffix .c,$(MAIN))
RNDR_C = $(addsuffix .c,$(RNDR))

MAIN_RO = $(addsuffix .r.bc,$(MAIN))
RNDR_RO = $(addsuffix .r.bc,$(RNDR))

MAIN_DO = $(addsuffix .d.bc,$(MAIN))
RNDR_DO = $(addsuffix .d.bc,$(RNDR))

MAIN_PRE = main-pre.js
RNDR_PRE = rndr-pre.js

INDEX = index.html

# 
# prepack targets
#

REL_PRE = r-js
DBG_PRE = d-js

REL_PREPACK = $(REL_PRE)/main.js $(REL_PRE)/rndr.js
DBG_PREPACK = $(DBG_PRE)/main.js $(DBG_PRE)/rndr.js

# 
# output directories
#

RELEASE = release
DEBUG = debug
PACK = pack

#
# build deps
# 

all: release

%.r.bc: %.c
	$(EMCC) $(CFLAGS) $(E_FLAGS) $< -o $@

%.d.bc: %.c
	$(EMCC) $(CFLAGS) $(E_FLAGS) $< -o $@

$(REL_PRE)/main.js: CFLAGS = $(REL_FLAGS)
$(REL_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_RO)) $(SRC)/$(MAIN_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(MAIN_PRE) $(filter-out $(SRC)/$(MAIN_PRE),$^) -o $@

$(REL_PRE)/rndr.js: CFLAGS = $(REL_FLAGS)
$(REL_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_RO)) $(SRC)/$(RNDR_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(RNDR_PRE) $(filter-out $(SRC)/$(RNDR_PRE),$^) -o $@

$(DBG_PRE)/main.js: CFLAGS = $(DBG_FLAGS)
$(DBG_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_DO)) $(SRC)/$(MAIN_PRE)
	echo $<
	mkdir -p $(DBG_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(MAIN_PRE) $(filter-out $(SRC)/$(MAIN_PRE),$^) -o $@

$(DBG_PRE)/rndr.js: CFLAGS = $(DBG_FLAGS)
$(DBG_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_DO)) $(SRC)/$(RNDR_PRE)
	mkdir -p $(DBG_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(RNDR_PRE) $(filter-out $(SRC)/$(RNDR_PRE),$^) -o $@

release: $(REL_PREPACK)
	$(WEBPACK) --config $(REL_CFG) 
	cp $(SRC)/$(INDEX) $(RELEASE)

debug: $(DBG_PREPACK)
	$(WEBPACK) $(W_FLAGS) --config $(DBG_CFG)
	cp $(SRC)/$(INDEX) $(DEBUG)

cc4watch: $(DBG_PREPACK)

watch: cc4watch
	$(WEBPACK) $(W_FLAGS) --watch --config $(DBG_CFG)

install: release
	cp package.json $(RELEASE)
	$(PACKAGER) ./$(RELEASE) --out $(PACK)

dist: release
	cp package.json $(RELEASE) 
	$(PACKAGER) ./$(RELEASE) --all --out $(PACK)

clean: 
	rm -rf $(PACK) $(RELEASE) $(DEBUG) $(DBG_PRE) $(REL_PRE) $(SRC)/*.d.bc $(SRC)/*.r.bc

