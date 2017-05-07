#include <stdio.h>
#include <string.h>

int main() {
    char buf[1000];
    fprintf(stderr, "Enter your message: ");
    fgets(buf, 1000, stdin);
    char *p = buf;
    printf("%lu\n", strlen(p));

    while (*p != 0) {
        printf("%d\n", (int)*p++);
    }
    return 0;
}
