
struct stone {
	/* actually a linked list of ints */
	int val;
};

struct mint {
	struct stone val;
	struct stone mod; //should be immutable
};

struct curve {
	struct mint a;
	struct mint b;	
};

struct point {
	struct curve c;
	struct stone x;
	struct stone y;
	int inf;
};

struct stone *access_m(struct mint x) {
	struct stone a[] = { x.val, x.mod }; 
	return &a[0];
}

struct stone *access_c(struct curve c) {
	struct stone *a = access_m(c.a);
	struct stone *b = access_m(c.b);
	struct stone z[] = { a[0], a[1], b[0], b[1] };
	return z;
}

struct stone *access_p(struct point p) {
	struct stone *c = access_c(p.c);
	struct stone a[] = { c[0], c[1], c[2], c[3], p.x, p.y };
	return a;
}

int main() {

	// construct 2 mints from 4 stones
	struct stone v;
	struct stone md;
	v.val = 12;
	md.val = 29;

	struct mint m;
	m.val = v;
	m.mod = md;

	struct stone v1;
	struct stone md1;
	v1.val = 13;
	md1.val = 29;

	struct mint m1;
	m1.val = v1;
	m1.mod = md1;

	// construct a curve from these mints
	struct curve c;
	c.a = m;
	c.b = m1;

	// construct a point from 2 stones and this curve
	struct stone x, y;
	x.val = 12;
	y.val = 13;

	struct point p;
	p.c = c;
	p.x = x;
	p.y = y;
	p.inf = 0;  // not infinity

	// test access

	return 0;

}

