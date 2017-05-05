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

struct curve *curve_create_func(struct mint a, struct mint b) {
    struct curve *E;
    E = (struct curve *)malloc(sizeof(struct curve));
    E->a = a;
    E->b = b;
    return E;
}

struct point *point_create_func(struct curve *E, void *a, void *b) {
    struct point *R;
    R = (struct point *)malloc(sizeof(struct point));
    R->E = *E;
    R->x = a;
    R->y = b;
    R->inf = 0;
    return R;
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
  if (BN_is_negative(r)) {
      BN_add(r, r, b);
  }
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

/* for point mult */

char *hex_to_bin_help(char *hx) {
    size_t len = strlen(hx);
    char *x = (char *)malloc(len * 4 + 1);
    char *buf;
    for (size_t j = 0; j < len; j = j + 1) {
        switch (*hx) {
            case '0':
                buf = "0000";
                break;
            case '1':
                buf = "0001";
                break;
            case '2':
                buf = "0010";
                break;
            case '3':
                buf = "0011";
                break;
            case '4':
                buf = "0100";
                break;
            case '5':
                buf = "0101";
                break;
            case '6':
                buf = "0110";
                break;
            case '7':
                buf = "0111";
                break;
            case '8':
                buf = "1000";
                break;
            case '9':
                buf = "1001";
                break;
            case 'A':
                buf = "1010";
                break;
            case 'B':
                buf = "1011";
                break;
            case 'C':
                buf = "1100";
                break;
            case 'D':
                buf = "1101";
                break;
            case 'E':
                buf = "1110";
                break;
            case 'F':
                buf = "1111";
                break;
        }
        for (int i = 0; i < 4; i++) {
            x[4*j+i] = buf[i];
        }
        hx++;
    }
    x[4*len] = '\0';
    return x;
}


void point_add_func_help(struct point *R, struct point *P, struct point *Q) {
    R->E = P->E;
    if (P->inf) {
        R->x = Q->x;
        R->y = Q->y;
        R->inf = Q->inf;
    } else if (Q->inf) {
        R->x = P->x;
        R->y = P->y;
        R->inf = P->inf;
    } else { /* neither points are inf */
        BIGNUM *xval = BN_new();
        BIGNUM *yval = BN_new();
        BN_CTX *ctx = BN_CTX_new();

        BIGNUM *lambda = BN_new();
        BIGNUM *t1 = BN_new();
        BIGNUM *t2 = BN_new();

        // calculate lambda
        BN_sub(t1, Q->y, P->y);
        BN_sub(t2, Q->x, P->x);
        if (BN_is_zero(t2)) {
            if (BN_is_zero(t1)) {
                /* same point, double it 
                 * calculate lambda this way */
                BN_mod_sqr(t1, P->x, P->E.a.mod, ctx);
                BN_mod_add(t2, t1, t1, P->E.a.mod, ctx); /* t2 = 2 t1 */
                BN_mod_add(t2, t1, t1, P->E.a.mod, ctx); /* t1 = t1 + t2 = 3t1 */
                BN_mod_add(t1, t1, t2, P->E.a.mod, ctx);
                BN_mod_add(t1, t1, P->E.a.val, P->E.a.mod, ctx);

                BN_mod_add(t2, P->y, P->y, P->E.a.mod, ctx); /* t2 = 2 P.y */
                BN_mod_inverse(t2, t2, P->E.a.mod, ctx);

                BN_mod_mul(lambda, t1, t2, P->E.a.mod, ctx);

            } else {
                /* additive inverses, return inf 
                 * Fill coords with junk values from P */
                R->x = P->x;
                R->y = P->y;
                R->inf = 1;
                BN_free(t1);
                BN_free(t2);
                BN_CTX_free(ctx);
                return;
            }
        } else {
            // finish calculating lambda for "normal" case
            BN_mod_inverse(t2, t2, P->E.a.mod, ctx);
            BN_mod_mul(lambda, t1, t2, P->E.a.mod, ctx);
        }

        //calculate xval
        BN_mod_sqr(t1, lambda, P->E.a.mod, ctx);
        BN_mod_sub(t1, t1, P->x, P->E.a.mod, ctx); 
        BN_mod_sub(xval, t1, Q->x, P->E.a.mod, ctx); 
       
        //calculate yval     
        BN_mod_sub(t1, P->x, xval, P->E.a.mod, ctx);
        BN_mod_mul(t1, lambda, t1, P->E.a.mod, ctx);
        BN_mod_sub(yval, t1, P->y, P->E.a.mod, ctx);

        //put in values
        R->x = xval;
        R->y = yval;
        R->inf = P->inf;

        BN_free(t1);
        BN_free(t2);
        BN_CTX_free(ctx);
    }
}

struct point *point_add_func(struct point *P, struct point *Q) {
    struct point *R;
    R = (struct point *)malloc(sizeof(struct point));
    point_add_func_help(R, P, Q);
    return R;
}  

struct point *point_sub_func(struct point *P, struct point *Q) {
    ((BIGNUM *) Q->y)->neg = !((BIGNUM *) Q->y)->neg;
    struct point *R;
    R = point_add_func(P, Q);
    /* restore neg value of Q */
    ((BIGNUM *) Q->y)->neg = !((BIGNUM *) Q->y)->neg;
    return R;
}

struct point *point_mult_func(void *k, struct point *P) {
    char *x;
    char *z;
    BIGNUM *y;
    y = stone_create_func("26");
    z = BN_bn2hex((BIGNUM *) k);
    x = hex_to_bin_help(z);
    z = x; // free this at the end
    struct point *R;
    R = (struct point *)malloc(sizeof(struct point));
    R->E = P->E;
    R->x = P->x;
    R->y = P->y;
    R->inf = (*x) == '0' ? 1 : P->inf;
    // if first bit is 0, then return infinity.
    // this fixes leading zeroes in the binary string
    // else, set result equal to P
    while (*x != '\0') {
        // if bit is 1, R = 2R + P
        // if bit is 0, R = 2R
        point_add_func_help(R, R, R);
        if (*x++ == '1') {
            point_add_func_help(R, R, P);
        }
    }
    free(z);
    return R;
}

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
    if (BN_is_negative((BIGNUM *)b)) {
        BN_mod_inverse(a->val, a->val, a->mod, ctx);
    }
    BN_mod_exp(val, a->val, b, a->mod, ctx); 
    /* BN_mod_exp takes the absolute value of b. 
     * This is why this works */
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
    printf("<%s, %s>\n", BN_bn2dec(a.val), BN_bn2dec(a.mod));
    return 0;
}

int point_print_func(struct point *P) {
    //mint_print_func(P.E.a);
    //mint_print_func(P.E.b);
    if (P->inf) {
        printf("inf\n");
    } else {
        printf("<%s, %s>\n", BN_bn2dec(P->x), BN_bn2dec(P->y));
    }
    //stone_print_func(P.x);
    //stone_print_func(P.y);
    return 0;
}

int curve_print_func(struct curve *E) {
    printf("a: %s\nb: %s\np: %s\n", BN_bn2dec(E->a.val), BN_bn2dec(E->b.val), 
            BN_bn2dec(E->a.mod));
    return 0;
}

//Equality and Inequality ops ofr mints are in LRM, 
//but we can hold off on implemenitng

/*
* @Michael other stuff that is left is point/curve ops
* thats your expertise so ill leave it to you to 
* define the headers and functions in the same way as above
*/


