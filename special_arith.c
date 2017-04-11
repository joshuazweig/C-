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

/*
* Stone
* We will need to implement these based on the bignum
* library. Implement all others assuming you have these
* functions. 
*/

//Add
void* stone_add_func(void *a, void *b);

//Multiply

//Divide

//Mod 

/*
* Mint
*/

//Mint addition 
struct mint* mint_add_func(struct mint *a, struct mint *b);


//mint raised to stone 
struct mint* mint_to_stone_func(struct mint *a, struct stone *b);



