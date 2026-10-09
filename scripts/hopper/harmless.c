#include <stdio.h>
__attribute__((noinline)) int demo_add(int a, int b) { return a + b; }
__attribute__((noinline)) int demo_check(int value) { return value == 42; }
int main(void) {
    puts("HOPPER_REA_HARMLESS_ELF_TEST");
    return demo_check(demo_add(19, 23)) ? 0 : 1;
}
