#include <stdio.h>
#include <string.h> 
#include <stdlib.h> 
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

int print_stone(void *a)
{
  BN_print_fp(stdout, a); //This is hex
  return 0; 
}
//construct
void* stone_char_func(void *buf, void *bn)
{
  //printf("%s\n", (const unsigned char*) buf);
  //printf("Length : %d\n", strlen(buf));
  BIGNUM *c = BN_bin2bn((unsigned char*) buf, strlen(buf), bn);
  
  BN_print_fp(stdout, c);
  printf("\n");
  
  return c;
}

//Add
void* stone_add_func(void *r, void *a, void *b)
{
  BN_add(r, a, b);

  BN_print_fp(stderr, r);
  printf("\n");

  return r;

}

//Multiply
void* stone_mult_func(void *r, void *a, void *b)
{
  BN_CTX* ctx = BN_CTX_new();
  BN_mul(r, a, b, ctx);
  BN_CTX_free(ctx);

  BN_print_fp(stderr, r);

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
//TODO
struct mint mint_add_func(struct mint *a, struct mint *b);
/*{
  struct mint x;

  BIGNUM *n = BN_new();
  BN_CTX* ctx = BN_CTX_new();


  BN_mod_add(n, ((struct stone)a->val).val, ((struct stone)b->val).val, ((struct stone)a->mod).val, ctx);
  //x = {{n}, {((struct stone)a->mod).val}}
  //x.val = 

  BN_CTX_free(ctx);
  //printf("%s", x.mod);

  return x; 
  
}*/

//Multiply
struct mint* mint_mult_func(struct mint *a, struct mint *b);

//Exponent
struct mint* mint_exp_func(struct mint *a, struct mint *b);

//Equality and Inequality ops ofr mints are in LRM, 
//but we can hold off on implemenitng


//mint raised to stone 
struct mint mint_to_stone_func(struct mint *a, void *b)
{
  //mint has stone (val, mod) each is stone has val

  BIGNUM *n = BN_new();
  BN_CTX* ctx = BN_CTX_new();

  struct stone base = a->val;
  struct stone mod = a->mod;

  BN_mod_exp(n, base.val, b, mod.val, ctx);

  //What it should be 
  /*struct mint x;
  struct stone temp;
  temp.val = (void *) n;
  x.val = temp;
  x.mod = mod;

  return x;*/

}


/*
* @Michael other stuff that is left is point/curve ops
* thats your expertise so ill leave it to you to 
* define the headers and functions in the same way as above
*/





