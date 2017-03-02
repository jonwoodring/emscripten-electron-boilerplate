# 
# executables
#

EMCC = emcc
WEBPACK = node ./node_modules/.bin/webpack
PACKAGER = node ./node_modules/.bin/electron-packager

#
# emscripen flags
#

REL_FLAGS = -O3
DBG_FLAGS = -g
E_FLAGS = -v --memory-init-file 0 --closure 0

# 
# webpack debug flags
#

REL_CFG = release.config.js
DBG_CFG = debug.config.js
W_FLAGS = --verbose --display-reasons --debug --display-modules --display-error-details --progress --colors

#
# source directories and files
#

SRC = src

MAIN_C = main
RNDR_C = rndr

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

%.r.bc: CFLAGS = $(REL_FLAGS)
%.r.bc: %.c
	$(EMCC) $(CFLAGS) $(E_FLAGS) $< -o $@

%.d.bc: CFLAGS = $(DBG_FLAGS)
%.d.bc: %.c
	$(EMCC) $(CFLAGS) $(E_FLAGS) $< -o $@

$(REL_PRE)/main.js: CFLAGS = $(REL_FLAGS)
$(REL_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_C)).r.bc $(SRC)/$(MAIN_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(MAIN_PRE) $< -o $@

$(REL_PRE)/rndr.js: CFLAGS = $(REL_FLAGS)
$(REL_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_C)).r.bc $(SRC)/$(RNDR_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(RNDR_PRE) $< -o $@

$(DBG_PRE)/main.js: CFLAGS = $(DBG_FLAGS)
$(DBG_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_C)).d.bc $(SRC)/$(MAIN_PRE)
	mkdir -p $(DBG_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(MAIN_PRE) $< -o $@

$(DBG_PRE)/rndr.js: CFLAGS = $(DBG_FLAGS)
$(DBG_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_C)).d.bc $(SRC)/$(RNDR_PRE)
	mkdir -p $(DBG_PRE)
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $(SRC)/$(RNDR_PRE) $< -o $@

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

