#include <stdio.h>

struct stone {
    /* actually a linked list of ints */
    // int val;
    void *val;
};
struct mint {
    struct stone val;
    struct stone mod; //should be immutable
    int a;
};

void * stone_add_func()
struct mint* mint_add_func(struct mint *a, struct mint *b)
{
  printf("We made it!\n");
  return a;  

}



