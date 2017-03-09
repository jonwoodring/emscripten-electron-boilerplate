MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

all: exe

#
# executables
#

EMCC = emcc
WEBPACK = node --max_old_space_size=8192 ./node_modules/.bin/webpack --progress
PACKAGER = node ./node_modules/.bin/electron-packager
WGET = wget
UNZIP = unzip

#
# emscripten flags
#

# NOTE: add include and library directories here
# -s AGGRESSIVE_VARIABLE_ELIMINATION=1
# -s SIMD=1
# It's important to have the same -O flag for everything
# otherwise you will get run-time errors
C_FLAGS = -s TOTAL_MEMORY=67108864
REL_FLAGS = -Oz $(C_FLAGS) -s NO_DYNAMIC_EXECUTION=1 -s ASSERTIONS=0
DBG_FLAGS = -g -Os $(C_FLAGS) -s STACK_OVERFLOW_CHECK=2 -s SAFE_HEAP=1 -s ASSERTIONS=2 -s ABORTING_MALLOC=1
LINK_FLAGS = --memory-init-file 0 --closure 0
REL_LINK_FLAGS = $(REL_FLAGS) $(LINK_FLAGS)
DBG_LINK_FLAGS = $(DBG_FLAGS) $(LINK_FLAGS)

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

# NOTE: add additional c source files here
MAIN = main
RNDR = rndr

MAIN_FLAGS = -s EXPORTED_FUNCTIONS="['_main']"
RNDR_FLAGS = -s EXPORTED_FUNCTIONS="['_main']"

MAIN_R_PRE = main-pre.r.js
RNDR_R_PRE = rndr-pre.r.js

MAIN_D_PRE = main-pre.d.js
RNDR_D_PRE = rndr-pre.d.js

INDEX = index.html

MAIN_C = $(addsuffix .c,$(MAIN))
RNDR_C = $(addsuffix .c,$(RNDR))

MAIN_RO = $(addsuffix .r.bc,$(MAIN))
RNDR_RO = $(addsuffix .r.bc,$(RNDR))

MAIN_DO = $(addsuffix .d.bc,$(MAIN))
RNDR_DO = $(addsuffix .d.bc,$(RNDR))

MAIN_DEP = $(addsuffix .d,$(MAIN))
RNDR_DEP = $(addsuffix .d,$(RNDR))

#
# linking for libraries and externals
#

SEARCH = -Ilib/sqlite-amalgamation-3170000/

LIBS = lib
REL_LIBS = $(LIBS)/rel
DBG_LIBS = $(LIBS)/dbg

# NOTE: add additional externals and libraries here
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
# libraries
#

# sqlite 3.17
SQL_ZIP = sqlite-amalgamation-3170000.zip
SQL_HTTP = https://www.sqlite.org/2017/$(SQL_ZIP)
SQL_VER = sqlite-amalgamation-3170000
SQL_FLAGS = -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1 -DSQLITE_LIKE_DOESNT_MATCH_BLOBS -DSQLITE_MAX_EXPR_DEPTH=0 -DSQLITE_OMIT_DECLTYPE -DSQLITE_OMIT_DEPRECATED -DSQLITE_OMIT_PROGRESS_CALLBACK -DSQLITE_OMIT_SHARED_CACHE -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_DISABLE_LFS -DLONGDOUBLE_TYPE=double -DSQLITE_INT64_TYPE="long long int" -DSQLITE_THREADSAFE=0 -DSQLITE_ENABLE_JSON1

$(LIBS)/$(SQL_ZIP):
	mkdir -p $(LIBS)
	cd $(LIBS) ; $(WGET) $(SQL_HTTP)

$(LIBS)/$(SQL_VER): | $(LIBS)/$(SQL_ZIP)
	cd $(LIBS) ; $(UNZIP) $(SQL_ZIP)

$(REL_LIBS)/sqlite3.bc: | $(LIBS)/$(SQL_VER)
	mkdir -p $(REL_LIBS)
	$(EMCC) $(REL_FLAGS) $(SQL_FLAGS) -o $(REL_LIBS)/sqlite3.bc $(LIBS)/$(SQL_VER)/sqlite3.c

$(DBG_LIBS)/sqlite3.bc: | $(LIBS)/$(SQL_VER)
	mkdir -p $(DBG_LIBS)
	$(EMCC) $(DBG_FLAGS) $(SQL_FLAGS) -o $(DBG_LIBS)/sqlite3.bc $(LIBS)/$(SQL_VER)/sqlite3.c

sqlite: $(REL_LIBS)/sqlite3.bc $(DBG_LIBS)/sqlite3.bc

clean-sqlite:
	rm -rf $(REL_LIBS) $(DBG_LIBS) $(LIBS)/$(SQL_ZIP) $(LIBS)/$(SQL_VER)

#
# build deps
#

# make release bytecode
%.r.bc: %.c %.d $(MAIN_REL) $(RNDR_REL) Makefile
	$(EMCC) $(SEARCH) -MT $*.r.bc -M -MP $< > $*.d
	$(EMCC) $(SEARCH) -Werror $(REL_FLAGS) $< -o $@

# make debug bytecode
%.d.bc: %.c %.d $(MAIN_DBG) $(RNDR_DBG) Makefile
	$(EMCC) $(SEARCH) -MT $*.d.bc -M -MP $< > $*.d
	$(EMCC) $(SEARCH) -Werror $(DBG_FLAGS) $< -o $@

# make deps
%.d: ;
.PRECIOUS: %.d

depend: main-dep rndr-dep

main-dep: $(addprefix $(SRC)/,$(addsuffix .Td,$(MAIN)))

rndr-dep: $(addprefix $(SRC)/,$(addsuffix .Td,$(RNDR)))

%.Td: %.c
	$(EMCC) $(SEARCH) -MT $*.d.bc -M -MP $< > $*.Td
	mv $*.Td $*.d

# dep includes are at the very end to not clobber %.c rules

# make release main.js
$(REL_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_RO)) $(MAIN_REL) $(SRC)/$(MAIN_R_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(REL_LINK_FLAGS) $(MAIN_FLAGS) --pre-js $(SRC)/$(MAIN_R_PRE) $(filter-out $(SRC)/$(MAIN_R_PRE),$^) -o $@

# make release rndr.js
$(REL_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_RO)) $(RDNR_REL) $(SRC)/$(RNDR_R_PRE)
	mkdir -p $(REL_PRE)
	$(EMCC) $(REL_LINK_FLAGS) $(RNDR_FLAGS) --pre-js $(SRC)/$(RNDR_R_PRE) $(filter-out $(SRC)/$(RNDR_R_PRE),$^) -o $@

# make debug main.js
$(DBG_PRE)/main.js: $(addprefix $(SRC)/,$(MAIN_DO)) $(MAIN_DBG) $(SRC)/$(MAIN_D_PRE)
	mkdir -p $(DBG_PRE)
	$(EMCC) $(DBG_LINK_FLAGS) $(MAIN_FLAGS) --pre-js $(SRC)/$(MAIN_D_PRE) $(filter-out $(SRC)/$(MAIN_D_PRE),$^) -o $@

# make debug rndr.js
$(DBG_PRE)/rndr.js: $(addprefix $(SRC)/,$(RNDR_DO)) $(RNDR_DBG) $(SRC)/$(RNDR_D_PRE)
	mkdir -p $(DBG_PRE)
	$(EMCC) $(DBG_LINK_FLAGS) $(RNDR_FLAGS) --pre-js $(SRC)/$(RNDR_D_PRE) $(filter-out $(SRC)/$(RNDR_D_PRE),$^) -o $@

# webpack release
release: $(REL_PREPACK)
	$(WEBPACK) --config $(REL_CFG)
	cp $(SRC)/$(INDEX) $(RELEASE)

# webpack debug
debug: $(DBG_PREPACK)
	$(WEBPACK) $(W_FLAGS) --config $(DBG_CFG)
	cp $(SRC)/$(INDEX) $(DEBUG)

# compile for linting
lint: $(addprefix $(SRC)/,$(MAIN_DO)) $(addprefix $(SRC)/,$(RNDR_DO))

# compile for webpack watching
cc: $(DBG_PREPACK)

# webpack watching
watch: cc
	mkdir -p $(DEBUG)
	cp $(SRC)/$(INDEX) $(DEBUG)
	$(WEBPACK) $(W_FLAGS) --watch --config $(DBG_CFG)

# make an electron distributable for this platform
exe: release
	cp package.json $(RELEASE)
	$(PACKAGER) ./$(RELEASE) --out $(PACK)

# make all electron distributables
dist: release
	cp package.json $(RELEASE)
	$(PACKAGER) ./$(RELEASE) --all --out $(PACK)

# clean up build stuff
clean-dep:
	rm -rf $(SRC)/*.d

clean: clean-dep
	rm -rf $(RELEASE) $(DEBUG) $(DBG_PRE) $(REL_PRE) $(SRC)/*.d.bc $(SRC)/*.r.bc

clean-dist:
	rm -rf $(PACK)

clean-all: clean clean-dist clean-dep
	rm -rf $(LIBS)

# dep files
# at the end to not clobber %.c rules
include $(addprefix $(SRC)/,$(MAIN_DEP))
include $(addprefix $(SRC)/,$(RNDR_DEP))

