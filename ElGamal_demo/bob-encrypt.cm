int main() {
    stone g_div;
    stone h_div;
    stone p;
    mint g;
    mint h;

    //public keys
    p = "977";
    g_div = "3";
    h_div = "249";  //alice's g^x for her secret x
    g = <g_div, p>;
    h = <h_div, p>;

    //bob's private key
    stone y;
    y = "77";

    //shared secret g^xy
    mint s;
    s = h^y;
    
    char *x;
    x = malloc(100);
    int msg_len;
    int i;
    scanf(x);
    msg_len = atoi(x);
    printf("%s\n", x);
    for (i = 0; i < msg_len; i = i + 1) {
        scanf(x);
        stone z_div;
        mint z;
        z_div = x;
        z = <z_div, p>;

        print_div(g^y);
        print_div(z * s);
    }
}



