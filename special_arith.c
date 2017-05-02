#include <stdio.h>
#include <string.h> 
#include <stdlib.h> 
#include <openssl/bn.h>

struct mint {
    void *val;
    void *mod; //should be immutable
};

struct curve {
    struct mint a;
    struct mint b;
};

struct point {
    struct curve E;
    void *x;
    void *y;
    char inf;
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
  printf("%s\n", BN_bn2dec(a));
  return 0; 
}
//construct

void *stone_create_func(char *str) {
    BIGNUM *r = BN_new();
    BN_dec2bn(&r, str);
    //fprintf(stderr, "Creating %p\n", r);

    return r;
}

int stone_free_func(void *a){
  //fprintf(stderr, "Freeing  %p\n", a);

  BN_free(a);
  return 0;
}

//Add
void* stone_add_func(void *a, void *b)
{
  BIGNUM *r = BN_new();
  //fprintf(stderr, "a: %p\nb: %p\n", a, b);
  //fprintf(stderr, "Creating to add %p\n", r);

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

/*struct point point_add_func(struct point P, struct point Q) {
    struct point R;
    R.E = P.E;
    if (P.inf) {
        R.x = Q.x;
        R.y = Q.y;
        R.inf = Q.inf;
    } else if (Q.inf) {
        R.x = P.x;
        R.y = P.y;
        R.inf = P.inf;
    } else {
        
    }
}*/


/*
* Mint
*/

//Add 
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
    printf("%s\n", BN_bn2dec(a.val));
    printf("%s\n", BN_bn2dec(a.mod));
    return 0;
}

//Equality and Inequality ops ofr mints are in LRM, 
//but we can hold off on implemenitng

/*
* @Michael other stuff that is left is point/curve ops
* thats your expertise so ill leave it to you to 
* define the headers and functions in the same way as above
*/


