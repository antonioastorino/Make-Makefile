#include <stdio.h>
#include "MMFCFunctions.h"
#include "common.h"

void helloFromC() { printf("Hello from C!\n"); }

#if TEST == 1
void test_from_c(void)
{
    printf("This is a test from C\n");
    helloFromC();
}
#endif
