#include <stdio.h>
#include <stdlib.h>
#include "types.h"

struct stone *access_mint(struct mint x) {

	struct stone *a = (struct stone *) malloc(2 * sizeof(struct stone));
	a[0] = x.val;
	a[1] = x.mod;

	// printf("REDUCED MINT: %d, %d\n", *((int *)a[0].val), *((int *)a[1].val));
	return a;
}

struct stone *access_curve(struct curve c) {
	struct stone *a = access_m(c.a);
	struct stone *b = access_m(c.b);


	struct stone *z = (struct stone *) malloc(4 * sizeof(struct stone));
	z[0] = a[0];
	z[1] = a[1];
	z[2] = b[0];
	z[3] = b[1];

	// printf("REDUCED CURVE: <%d, %d>, <%d, %d>\n", *((int *)z[0].val), *((int *)z[1].val), *((int *)z[2].val), *((int *)z[3].val));
	return z;
}

struct stone *access_point(struct point p) {
	struct stone *c = access_c(p.c);

	struct stone *a = (struct stone *) malloc(6 * sizeof(struct stone));
	a[0] = c[0];
	a[1] = c[1];
	a[2] = c[2];
	a[3] = c[3];
	a[4] = p.x;
	a[5] = p.y;

	// printf("REDUCED POINT: {<%d, %d>, <%d, %d>}, %d, %d\n", *((int *)a[0].val), *((int *)a[1].val), *((int *)a[2].val), *((int *)a[3].val), *((int *)a[4].val), *((int *)a[5].val));
	return a;
}



int main() {

	
	int a = 12;
	int b = 29; 
	int c = 13;
	int d = 31;
	int e = 53;
	int f = 37;

	// construct 2 mints from 4 stones
	struct stone v;
	struct stone md;

	v.val = &a;
	md.val = &b;

	struct mint m;
	m.val = v;
	m.mod = md;

	struct stone v1;
	struct stone md1;
	v1.val = &c;
	md1.val = &d;

	struct mint m1;
	m1.val = v1;
	m1.mod = md1;

	// construct a curve from these mints
	struct curve c1;
	c1.a = m;
	c1.b = m1;

	// construct a point from 2 stones and this curve
	struct stone x, y;
	x.val = &e;
	y.val = &f;

	struct point p;
	p.c = c1;
	p.x = x;
	p.y = y;
	p.inf = 0;  // not infinity

	// test access
/*
	printf("***Testing mint <12, 29>\n");
	struct stone *reduced_mint = access_mint(m);

	
	printf("***Testing curve {<12, 29>, <13, 31>}\n");
	struct stone *reduced_curve = access_curve(c1);

	printf("***Testing point {<12, 29>, <13, 31>}, 53, 37\n");
	struct stone *reduced_point = access_point(p);
*/


	return 0;

}
