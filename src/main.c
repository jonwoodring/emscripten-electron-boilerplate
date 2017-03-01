#include <emscripten.h>

void loop() {
}

int main(int argc, char* argv[])
{
  // Javascript preamble stuff (i.e., globals and modules)
  // are loaded in main-pre.js
  printf("hello from console\n");
  fflush(stdout);

  emscripten_set_main_loop(loop, 0, 1);
}
