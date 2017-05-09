// Defines all CMod Types

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
