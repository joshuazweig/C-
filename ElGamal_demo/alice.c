#include <stdio.h>
#include <stdlib.h>

int main() {
    char buf[1000];
    while (fgets(buf, 1000, stdin) != NULL) {
        printf("%c", atoi(buf)); //putchar
    }
    return 0;
}
