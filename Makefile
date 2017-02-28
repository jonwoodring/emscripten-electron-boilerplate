EMCC = emcc
WEBPACK = node ./node_modules/.bin/webpack
PACKAGER = node ./node_modules/.bin/electron-packager

E_FLAGS = -v --memory-init-file 0 --closure 0
W_FLAGS = --verbose --display-reasons --debug --display-modules --display-error-details --progress --colors

SRC = src
DEBUG = d-obj
RELEASE = r-obj

MAIN = main
RNDR = rndr

all: debug

$(DEBUG)/%.js : $(SRC)/%.c
	mkdir -p d-obj
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $<-pre.js $< -o $@

$(RELEASE)/%.js : $(SRC)/%.c
	mkdir -p r-obj
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js $<-pre.js $< -o $@

release: release-obj release-pack

debug: debug-obj debug-pack

release-obj: CFLAGS = -O3
release-obj: $(RELEASE)/$(MAIN).js $(RELEASE)/$(RNDR).js

debug-obj: CFLAGS = -g
debug-obj: $(DEBUG)/$(MAIN).js $(DEBUG)/$(RNDR).js

release-pack:
	$(WEBPACK) --config release.config.js 
	cp src/*.html release

debug-pack:
	$(WEBPACK) $(W_FLAGS) --config debug.config.js
	cp src/*.html debug

watch: 
	$(WEBPACK) $(W_FLAGS) --watch --config debug.config.js

dist: release
	cp package.json release
	$(PACKAGER) ./release --out pack

dist-all: release
	cp package.json release 
	$(PACKAGER) ./release --all --out pack

clean: 
	rm -rf pack release debug d-obj r-obj

