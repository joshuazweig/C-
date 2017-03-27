
struct stone {
	/* actually a linked list of ints */
	int val;
};

struct mint {
	stone val;
	const stone mod;
};

struct curve {
	mint a;
	mint b;	
};

struct point {
	curve c;
	stone x;
	stone y;
	int inf;
};

stone *access(mint x) {
	return stone a[] = { x.val, x.mod }; 
}

stone *access(curve c) {
	stone *a = access(c.a);
	stone *b = access(c.b);
	return stone a[] = { a[0], a[1], b[0], b[1] };
}

stone *access(point p) {
	stone *c = access(p.c);
	return stone a[] = { c[0], c[1], c[2], c[3], p.x, p.y };
}

int main() {

	// construct 2 mints from 4 stones
	struct stone v, md;
	v.val = 12;
	md.val = 29;

	struct mint m;
	m.val = v;
	m.mod = md;

	struct stone v1, md1;
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
	p.curve = c;
	p.x = x;
	p.y = y;
	p.inf = 0;  // not infinity

	// test access

}

