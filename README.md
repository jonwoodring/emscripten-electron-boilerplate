## A boilerplate Electron project using Emscripten ##

This is a boilerplate build for starting Electron projects
using Emscripten (i.e., C) as the source.

- combination of C and JS as the application source
- Electron for the application package
- Emscripten for compiling
- make for dependency building
- webpack for tree shaking, packing, uglify, watching, and babel of JS 
- electron-packager to create binary packages for platforms

Notes
=====

- make sure to do an `npm install` first, of course
- compiling uses `make` and running the tests uses `npm`
  - see `Makefile` and `package.json` and configure as necessary
- the default make rule `all` will build an Electron package
  - this should test release path building from soup to nuts
  - `make lint`, `make cc`, and `make watch` are useful development commands
- `make` expects Emscripten to be installed (i.e., `emcc` is on the `$PATH`)
  - I tested on 1.37.3 -- I know that 1.35 doesn't work (there will be an
    javascript error when it runs)
  - Emscripted C is not run through `babel` -- it's only for JS libraries
  - `octal-number-loader` is available in case non-standard octal numbers
    appear in the Emscripted C (octals in Javascript have to be 0o0001 now)
- `babel` is configured in `.babelrc`
- `webpack` is configured in `release.config.js` and `debug.config.js`
- an example external code is linked against, using `sqlite3` as the example 
  - it is fetched from the web and built as a dependency
- if you happen to change how things are compiled *make absolutely sure*
  that all of your LLVM bytecode files are compiled with the same -O flag --
  otherwise, you'll get lots of fun fatal run-time errors - this includes
  external libraries

TODO
====

- maybe add a `make` command that installs `emcc` -- maybe...

---

Use as you see fit, I claim no copyright over this.

![CC0-1.0](https://licensebuttons.net/p/zero/1.0/88x31.png)
