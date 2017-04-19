#include <stdio.h>
#include <string.h> 
#include <stdlib.h> 
#include <openssl/bn.h>

struct mint {
    void *val;
    void *mod; //should be immutable
};

/*
* Stone
* @Michael We will need to implement these based on the bignum
* library. Implement all others assuming you have these
* functions. Ill make some headway on this once I 
* come to a conclusion on a library 
*/

int stone_print_func(void *a)
{
  BN_print_fp(stdout, a); //This is hex
  printf("\n");
  return 0; 
}
//construct
void* stone_char_func(void *buf, void *bn)
{
  BIGNUM *c = BN_bin2bn((unsigned char*) buf, strlen(buf), bn);
   
  return c;
}

//Add
void* stone_add_func(void *a, void *b)
{
  BIGNUM *r = BN_new();
  BN_add(r, a, b);
  return r;
}

//Subtract
void* stone_sub_func(void *a, void *b)
{
  BIGNUM *r = BN_new();
  BN_sub(r, a, b);
  return r;
}

//Multiply
void* stone_mult_func(void *a, void *b)
{
  BIGNUM *r = BN_new();
  BN_CTX* ctx = BN_CTX_new();
  BN_mul(r, a, b, ctx);
  BN_CTX_free(ctx);

  return r;
}

//Divide
void* stone_div_func(void *a, void *b)
{
  BIGNUM *r = BN_new();
  BN_CTX *ctx = BN_CTX_new();
  BN_div(r, NULL, a, b, ctx);
  BN_CTX_free(ctx);

  return r;
}

//Mod 
void* stone_mod_func(void *a, void *b)
{
  BIGNUM *r = BN_new();
  BN_CTX* ctx = BN_CTX_new();
  BN_mod(r, a, b, ctx);
  BN_CTX_free(ctx);

  return r;
}

//Exponent
void* stone_pow_func(void *a, void *p)
{
  BIGNUM *r = BN_new();
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
struct mint mint_add_func(struct mint* a, struct mint* b) {
    BIGNUM *val = BN_new();
    BN_CTX *ctx = BN_CTX_new();

    //BN_mod_add_quick(val, v1, v2, v3);
    BN_mod_add(val, a->val, b->val, a->mod, ctx);
    BN_CTX_free(ctx);
    struct mint r;
    r.val = val;
    r.mod = a->mod; /* use a's modulus */
    return r; 
}

struct mint mint_sub_func(struct mint* a, struct mint* b) {
    BIGNUM *val = BN_new();
    BN_CTX *ctx = BN_CTX_new();

    BN_mod_sub(val, a->val, b->val, a->mod, ctx);
    BN_CTX_free(ctx);
    struct mint r;
    r.val = val;
    r.mod = a->mod; /* use a's modulus */
    return r; 
}

struct mint mint_mult_func(struct mint* a, struct mint* b) {
    BIGNUM *val = BN_new();
    BN_CTX *ctx = BN_CTX_new();

    BN_mod_mul(val, a->val, b->val, a->mod, ctx);
    BN_CTX_free(ctx);
    struct mint r;
    r.val = val;
    r.mod = a->mod; /* use a's modulus */
    return r; 
}

struct mint mint_to_stone_func(struct mint *a, void *b) {
    BIGNUM *val = BN_new();
    BN_CTX *ctx = BN_CTX_new();

    BN_mod_exp(val, a->val, b, a->mod, ctx); 
    BN_CTX_free(ctx);
    struct mint r;
    r.val = val;
    r.mod = a->mod;
    return r;
}

struct mint mint_pow_func(struct mint* a, struct mint* b) {
    return mint_to_stone_func(a, b->val);
}


/* testing function */

int mint_print_func(struct mint a) {
    printf("Value:  ");
    BN_print_fp(stdout, a.val);
    printf("\nModulus:");
    BN_print_fp(stdout, a.mod);
    printf("\n");
    return 0;
}

//Equality and Inequality ops ofr mints are in LRM, 
//but we can hold off on implemenitng


//mint raised to stone 
/*struct mint mint_to_stone_func(struct mint *a, void *b)
{
  //mint has stone (val, mod) each is stone has val

  BIGNUM *n = BN_new();
  BN_CTX* ctx = BN_CTX_new();

  struct stone base = a->val;
  struct stone mod = a->mod;

  BN_mod_exp(n, base.val, b, mod.val, ctx);

  //What it should be 
  struct mint x;
  struct stone temp;
  temp.val = (void *) n;
  x.val = temp;
  x.mod = mod;

  return x;

}*/


/*
* @Michael other stuff that is left is point/curve ops
* thats your expertise so ill leave it to you to 
* define the headers and functions in the same way as above
*/





