#ifndef MMFCFunctions_h
#define MMFCFunctions_h
#include "common.h"
#ifdef __cplusplus
extern "C"
{
#endif
    void helloFromC();


#if TEST == 1
void test_from_c();
#endif

#ifdef __cplusplus
};
#endif
#endif /* MMFCFunctions_h */