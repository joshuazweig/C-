#include <stdio.h>
#include <string.h> 
#include <openssl/bn.h>

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

//construct
void* stone_char_func(void *buf, void *bn)
{
  //printf("%s\n", (const unsigned char*) buf);
  //printf("Length : %d\n", strlen(buf));
  BIGNUM *c = BN_bin2bn((unsigned char*) buf, strlen(buf), bn);
  
  //BN_print_fp(stdout, c);
  //printf("%s\n", BN_bn2dec(c));
  
  return c;
}

//Add
void* stone_add_func(void *r, void *a, void *b)
{
  //BN_print_fp(stderr, a);
  //printf("\n");
  //BN_print_fp(stderr, b);
  //printf("\n");
  BN_add(r, a, b);

  //BN_print_fp(stderr, r);
  //printf("\n");

  return r;

}

//Multiply
void* stone_mult_func(void *r, void *a, void *b)
{
  BN_CTX* ctx = BN_CTX_new();
  BN_mul(r, a, b, ctx);
  BN_CTX_free(ctx);

  return r;
}

//Divide
void* stone_div_func(void *r, void *a, void *b)
{
  BN_CTX* ctx = BN_CTX_new();
  BN_div(r, NULL, a, b, ctx);
  BN_CTX_free(ctx);

  return r;
}

//Mod 
void* stone_mod_func(void *r, void *a, void *b)
{
  BN_CTX* ctx = BN_CTX_new();
  BN_mod(r, a, b, ctx);
  BN_CTX_free(ctx);

  return r;
}

//Exponent
void* stone_pow_func(void *r, void *a, void *p)
{
  BN_CTX* ctx = BN_CTX_new();
  BN_exp(r, a, p, ctx);
  BN_CTX_free(ctx);

  return r;
}

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





