int main() {
    stone g_div;
    stone h_div;
    stone p;
    mint g;
    mint h;

    //alice's private key
    stone y;
    stone y_neg;
    y = "131";
    y_neg = "-131";
    
    //public keys
    p = "977";
    g_div = "3";
    g = <g_div, p>;
    h = g^y;


    //shared secret g^xy
    mint s;
    
    char *x;
    x = malloc(100);
    while (2 == 2) {
        scanf(x);
        stone t_div;
        mint t;
        t_div = x;
        t = <t_div, p>;
        s = t^y_neg;

        scanf(x);
        stone z_div;
        mint z;
        z_div = x;
        z = <z_div, p>;
        print_div(z * s);
    }
    return 0;
}



