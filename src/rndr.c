#include <emscripten.h>

void loop() {
}

int main(int argc, char* argv[])
{
  // Javascript preamble stuff (i.e., globals and modules)
  // are loaded in rndr-pre.js
  printf("hello world\n");

  emscripten_set_main_loop(loop, 60, 1);
}
