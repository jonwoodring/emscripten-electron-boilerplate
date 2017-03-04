#include <emscripten.h>
#include <sqlite3.h>

int print_rows(void *NU, int argc, char **argv, char **names)
{
  printf("%s = %s", names[0], argv[0] ? argv[0] : "NULL");
  for(int i = 1; i < argc; i++) {
    printf(", %s = %s", names[i], argv[i] ? argv[i] : "NULL");
  }
  printf("\n");

  return 0;
}

void loop() {
}

int main(int argc, char* argv[])
{
  // Javascript preamble stuff (i.e., globals and modules)
  // are loaded in main-pre.js

  sqlite3 *db;
  int r;

  r = sqlite3_open(":memory:", &db);
  if (r) {
    fprintf(stderr, "Unable to open memory database: %s\n",
            sqlite3_errmsg(db));
  }

  char* error;
  r = sqlite3_exec(db, "create table foo (x real)", 0, 0, &error);
  if (r) {
    fprintf(stderr, "Unable to create table foo: %s\n",
            error);
    sqlite3_free(error);
  }

  r = sqlite3_exec(db, "with recursive cnt(x) as (select 1 union all select x+1 from cnt limit 100) insert into foo select * from cnt", 0, 0, &error);
  if (r) {
    fprintf(stderr, "Unable to insert into foo: %s\n",
            error);
    sqlite3_free(error);
  }

  r = sqlite3_exec(db, "select * from foo", print_rows, 0, &error);
  if (r) {
    fprintf(stderr, "Unable to select all from foo: %s\n",
            error);
    sqlite3_free(error);
  }

  r = sqlite3_exec(db, "select sum(x) from foo", print_rows, 0, &error);
  if (r) {
    fprintf(stderr, "Unable to select sum from foo: %s\n",
            error);
    sqlite3_free(error);
  }

  sqlite3_close(db); 

  emscripten_set_main_loop(loop, 0, 1);

  return 0; // should never happen
}

