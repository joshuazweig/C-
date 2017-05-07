int main() {
    curve *E;
    mint A;
    mint B;

    stone a;
    stone b;
    stone p;
    stone t;
    stone u;

    a = "7";
    b = "26";
    p = "61";

    A = <a, p>;
    B = <b, p>;
    E = <A, B>;

    point *P;
    point *Q;

    a = "25";
    b = "37";

    P = <E, a, b>;
    t = "13"; // alice's private key
    P = t * P;

    print_point(P); //send it over

    u = "23"; //magically get bob's private key
    Q = <E, a, b>;
    Q = u * Q;

    print_point(t * Q);
    return 0;
}
