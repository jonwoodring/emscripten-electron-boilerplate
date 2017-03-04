MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
	
# 
# executables
#

EMCC = emcc
WEBPACK = node --max_old_space_size=8192 ./node_modules/.bin/webpack --progress
PACKAGER = node ./node_modules/.bin/electron-packager
WGET = wget

#
# emscripten flags
#

SEARCH = -Ilib/sqlite-amalgamation-3170000/
REL_FLAGS = -Os $(SEARCH)
DBG_FLAGS = -g $(SEARCH)
JS_FLAGS = -s TOTAL_MEMORY=33554432
E_FLAGS = -v --memory-init-file 0 --closure 0
MAKE_FLAGS = -j4

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

MAIN_PRE = main-pre.js
RNDR_PRE = rndr-pre.js

INDEX = index.html

MAIN_C = $(addsuffix .c,$(MAIN))
RNDR_C = $(addsuffix .c,$(RNDR))

MAIN_RO = $(addsuffix .r.bc,$(MAIN))
RNDR_RO = $(addsuffix .r.bc,$(RNDR))

MAIN_DO = $(addsuffix .d.bc,$(MAIN))
RNDR_DO = $(addsuffix .d.bc,$(RNDR))

# 
# linking for libraries
#

LIBS = lib
REL_LIBS = $(LIBS)/rel
DBG_LIBS = $(LIBS)/dbg

MAIN_LIBS = sqlite3.bc
RNDR_LIBS =

MAIN_REL = $(addprefix $(REL_LIBS)/,$(MAIN_LIBS))
MAIN_DBG = $(addprefix $(DBG_LIBS)/,$(MAIN_LIBS))
RNDR_REL = $(addprefix $(REL_LIBS)/,$(RNDR_LIBS))
RNDR_DBG = $(addprefix $(DBG_LIBS)/,$(RNDR_LIBS))

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
	$(EMCC) $(CFLAGS) $(E_FLAGS) $(INCS) $< -o $@

%.d.bc: %.c
	$(EMCC) $(CFLAGS) $(E_FLAGS) $(INCS) $< -o $@

$(REL_PRE)/main.js: CFLAGS = $(REL_FLAGS)
$(REL_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_RO)) $(SRC)/$(MAIN_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(CFLAGS) $(JS_FLAGS) $(E_FLAGS) --pre-js $(SRC)/$(MAIN_PRE) $(filter-out $(SRC)/$(MAIN_PRE),$^) $(MAIN_REL) -o $@

$(REL_PRE)/rndr.js: CFLAGS = $(REL_FLAGS)
$(REL_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_RO)) $(SRC)/$(RNDR_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(CFLAGS) $(JS_FLAGS) $(E_FLAGS) --pre-js $(SRC)/$(RNDR_PRE) $(filter-out $(SRC)/$(RNDR_PRE),$^) $(RNDR_REL) -o $@

$(DBG_PRE)/main.js: CFLAGS = $(DBG_FLAGS)
$(DBG_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_DO)) $(SRC)/$(MAIN_PRE)
	echo $<
	mkdir -p $(DBG_PRE)
	$(EMCC) $(CFLAGS) $(JS_FLAGS) $(E_FLAGS) --pre-js $(SRC)/$(MAIN_PRE) $(filter-out $(SRC)/$(MAIN_PRE),$^) $(MAIN_DBG) -o $@

$(DBG_PRE)/rndr.js: CFLAGS = $(DBG_FLAGS)
$(DBG_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_DO)) $(SRC)/$(RNDR_PRE)
	mkdir -p $(DBG_PRE)
	$(EMCC) $(CFLAGS) $(JS_FLAGS) $(E_FLAGS) --pre-js $(SRC)/$(RNDR_PRE) $(filter-out $(SRC)/$(RNDR_PRE),$^) $(RNDR_DBG) -o $@

release: $(REL_PREPACK)
	$(WEBPACK) --config $(REL_CFG) 
	cp $(SRC)/$(INDEX) $(RELEASE)

debug: $(DBG_PREPACK)
	$(WEBPACK) $(W_FLAGS) --config $(DBG_CFG)
	cp $(SRC)/$(INDEX) $(DEBUG)

cc: $(DBG_PREPACK)

watch: cc
	$(WEBPACK) $(W_FLAGS) --watch --config $(DBG_CFG)

exe: release
	cp package.json $(RELEASE)
	$(PACKAGER) ./$(RELEASE) --out $(PACK)

dist: release
	cp package.json $(RELEASE) 
	$(PACKAGER) ./$(RELEASE) --all --out $(PACK)

clean: 
	rm -rf $(PACK) $(RELEASE) $(DEBUG) $(DBG_PRE) $(REL_PRE) $(SRC)/*.d.bc $(SRC)/*.r.bc

# 
# libraries
#

# sqlite 3.17
SQL_ZIP = sqlite-amalgamation-3170000.zip
SQL_HTTP = https://www.sqlite.org/2017/$(SQL_ZIP)
SQL_VER = sqlite-amalgamation-3170000
SQL_FLAGS = -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_DISABLE_LFS -DLONGDOUBLE_TYPE=double -DSQLITE_INT64_TYPE="long long int" -DSQLITE_THREADSAFE=0 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS

sqlite:
	mkdir -p $(REL_LIBS)
	mkdir -p $(DBG_LIBS)
	cd $(LIBS) ; wget $(SQL_HTTP) ; unzip $(SQL_ZIP)
	$(EMCC) $(REL_FLAGS) $(E_FLAGS) $(SQL_FLAGS) -o $(REL_LIBS)/sqlite3.bc $(LIBS)/$(SQL_VER)/sqlite3.c
	$(EMCC) $(DBG_FLAGS) $(E_FLAGS) $(SQL_FLAGS) -o $(DBG_LIBS)/sqlite3.bc $(LIBS)/$(SQL_VER)/sqlite3.c

clean-libs:
	rm -rf $(LIBS)
