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
* @Michael We will need to implement these based on the bignum
* library. Implement all others assuming you have these
* functions. Ill make some headway on this once I 
* come to a conclusion on a library 
*/

//Add
void* stone_add_func(void *a, void *b);

//Multiply
void* stone_mult_func(void *a, void *b);

//Divide
void* stone_div_func(void *a, void *b);

//Mod 
void* stone_mod_func(void *a, void *b);

//Exponent
void* stone_exp_func(void *a, void *b);

/*
* Mint
*/

//Add 
struct mint* mint_add_func(struct mint *a, struct mint *b);

//Multiply
struct mint* mint_mult_func(struct mint *a, struct mint *b);

//Exponent
struct mint* mint_exp_func(struct mint *a, struct mint *b);

//Equality and Inequality ops ofr mints are in LRM, 
//but we can hold off on implemenitng


//mint raised to stone 
struct mint* mint_to_stone_func(struct mint *a, struct stone *b);


/*
* @Michael other stuff that is left is point/curve ops
* thats your expertise so ill leave it to you to 
* define the headers and functions in the same way as above
*/




