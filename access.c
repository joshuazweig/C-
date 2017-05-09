#include <stdio.h>
#include <string.h> 
#include <stdlib.h> 
#include <openssl/bn.h>
#include "types.h"
// NEED TO LINK IN SPECIAL_ARITH

// void *access_m(struct mint x) {

// 	struct stone *a = (struct stone *) malloc(2 * sizeof(struct stone));
// 	a[0] = x.val;
// 	a[1] = x.mod;

// 	// printf("REDUCED MINT: %d, %d\n", *((int *)a[0].val), *((int *)a[1].val));
// 	return a;
// }

// takes a mint and an int (0 or 1), 
// returning val for idx 0 and mod for idx 1
// void *access_mint(struct mint* m, int index)	{
void *access_mint(struct mint m, int index)	{

	if(index == 0) { return m.val; }
	return m.mod;
}



void *access_curve(struct curve c, int index)	{
	
	if(index < 2) {
		return access_mint(c.a, index);
	}
	else {
		return access_mint(c.b, index-2);
	}

}
/*
void *access_point(struct point* p, int index)	{

	if(index < 4)	{
		return access_curve(&(p->E), index);
	}
	else	{
		BIGNUM *r = BN_new();
		if(index == 4) {
			BN_dec2bn(&r, (char *) p->x);
		}
		else {
			BN_dec2bn(&r, (char *) p->y);
		}
		char *bn = BN_bn2dec(r);
		BN_clear_free(r);
		return bn;
	}
}*/

/*
int main() {
	
	struct mint m;
	m.val = "5";
	m.mod = "31";

	char *mintmod;
	mintmod = access_mint(&m, 1);
	printf("Access mint: (31=) %s\n", mintmod);

	struct mint m1;
	m1.val="6";
	m1.mod = "31";

	struct curve c;
	c.a = m;
	c.b = m1;

	char *curveval2;
	curveval2 = access_curve(&c, 2);
	printf("Access curve: (6=) %s\n", curveval2);

	struct point p;
	p.E = c;
	p.x = "37";
	p.y = "53";

	char *pointx;
	pointx = access_point(&p, 4);
	printf("Access point: (37=) %s\n", pointx);


}	*/



