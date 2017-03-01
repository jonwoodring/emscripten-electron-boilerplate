EMCC = emcc
WEBPACK = node ./node_modules/.bin/webpack
PACKAGER = node ./node_modules/.bin/electron-packager

E_FLAGS = -v --memory-init-file 0 --closure 0
W_FLAGS = --verbose --display-reasons --debug --display-modules --display-error-details --progress --colors

MAIN = main
RNDR = rndr

all: debug

release: release-obj release-js release-pack

debug: debug-obj debug-js debug-pack

r-obj/%.bc: src/%.c
	mkdir -p r-obj
	$(EMCC) $(CFLAGS) $(E_FLAGS) $< -o $@

d-obj/%.bc: src/%.c
	mkdir -p d-obj
	$(EMCC) $(CFLAGS) $(E_FLAGS) $< -o $@

r-js/main.js: r-obj/$(MAIN).bc
	mkdir -p r-js
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js src/main-pre.js r-obj/$(MAIN).bc -o r-js/main.js

r-js/rndr.js: r-obj/$(RNDR).bc
	mkdir -p r-js
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js src/rndr-pre.js r-obj/$(RNDR).bc -o r-js/rndr.js

d-js/main.js: d-obj/$(RNDR).bc
	mkdir -p d-js
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js src/main-pre.js d-obj/$(MAIN).bc -o d-js/main.js

d-js/rndr.js: d-obj/$(RNDR).bc
	mkdir -p d-js
	$(EMCC) $(CFLAGS) $(E_FLAGS) --pre-js src/rndr-pre.js d-obj/$(RNDR).bc -o d-js/rndr.js

release-obj: CFLAGS = -O3
release-obj: r-obj/$(MAIN).bc r-obj/$(RNDR).bc

debug-obj: CFLAGS = -g
debug-obj: d-obj/$(MAIN).bc d-obj/$(RNDR).bc

release-js: CFLAGS = -O3
release-js: r-js/main.js r-js/rndr.js

debug-js: CFLAGS = -g
debug-js: d-js/main.js d-js/rndr.js

release-pack: release-js
	$(WEBPACK) --config release.config.js 
	cp src/*.html release

debug-pack: debug-js
	$(WEBPACK) $(W_FLAGS) --config debug.config.js
	cp src/*.html debug

cc4watch: debug-js

watch: debug-js
	$(WEBPACK) $(W_FLAGS) --watch --config debug.config.js

dist: release
	cp package.json release
	$(PACKAGER) ./release --out pack

dist-all: release
	cp package.json release 
	$(PACKAGER) ./release --all --out pack

clean: 
	rm -rf pack release debug d-obj r-obj d-js r-js

