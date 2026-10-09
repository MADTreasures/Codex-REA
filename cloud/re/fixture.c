#include <stdio.h>

__attribute__((noinline)) int re_add(int left, int right) {
    return left + right;
}

__attribute__((noinline)) int re_score(int value) {
    return value > 7 ? re_add(value, 3) : re_add(value, 1);
}

int main(void) {
    printf("REA harmless ELF fixture: %d\n", re_score(9));
    return 0;
}
