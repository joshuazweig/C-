// Defines all CMod Types


struct stone {
	/* actually a linked list of ints */
	// int val;
	void *val;
};

struct mint {
	struct stone val;
	struct stone mod; //should be immutable
	int a;   //padding for struct unpacking
};

struct curve {
	struct mint a;
	struct mint b;	
	int i; //padding for struct unpacking
};

struct point {
	struct curve c;
	struct stone x;
	struct stone y;
	int inf;
};