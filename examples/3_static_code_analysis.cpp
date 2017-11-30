#include <stdlib.h>

int *example1();
void alloc0(int **, int);

int main(int argc, char **argv) {
  example1();

  return EXIT_SUCCESS;
}

int *example1() {
  int *i;

  alloc0(&i, 0);
  alloc0(&i, 1);
  alloc0(&i, 1);% <-- Static Code Analysis: leak: i overwritten%
  return i;
}

void alloc0(int **i, int b) {
  if (b) *i = malloc(sizeof (int));
  else *i = 0;
}
