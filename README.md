## A boilerplate Electron project using Emscripten ##

This is a boilerplate build for starting Electron projects
using Emscripten (i.e., C) as the source.

- Electron for the application package
- combination of C and JS as the application source
- webpack for tree shaking, packing, uglify, watching, and babel
- Emscripten and make for compiling
- electron-packager to create binary packages for platforms

Notes
=====

- compiling uses `make` and running the tests uses `npm`
  - see `Makefile` and `package.json`
- `make` expects Emscripten to be installed (i.e., `emcc` is on the `$PATH`)
  - I tested on 1.37.3 -- I know that 1.35 doesn't work (there will be an
    javascript error when it runs)
- `babel` is configured in `.babelrc`
- `webpack` is configured in `release.config.js` and `debug.config.js`

---

Use as you see fit, I claim no copyright over this.

![CC0-1.0](https://licensebuttons.net/p/zero/1.0/88x31.png)
