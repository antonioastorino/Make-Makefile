#ifndef MMFCFunctions_h
#define MMFCFunctions_h
#include "common.h"
#ifdef __cplusplus
extern "C"
{
#endif
    void helloFromC(void);

#if TEST == 1
    void test_from_c(void);
#endif

#ifdef __cplusplus
};
#endif
#endif /* MMFCFunctions_h */
