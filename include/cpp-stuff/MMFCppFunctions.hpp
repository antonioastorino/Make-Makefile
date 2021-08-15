#ifndef MMFCppFunctions_hpp
#define MMFCppFunctions_hpp
#include "common.h"

class MMFCppFunctions {
public:
    static void helloFromCpp();
};

#if TEST == 1
void test_from_cpp();
#endif

#endif /* MMFCppFunctions_hpp */