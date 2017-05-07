#include <stdio.h>

int main() {
    char buf[1000];
    fprintf(stderr, "Enter your message: ");
    fgets(buf, 1000, stdin);
    char *p = buf;

    while (*p != 0) {
        printf("%d\n", (int)*p++);
    }
    return 0;
}
