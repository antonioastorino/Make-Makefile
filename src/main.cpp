#include "common.h"
#if TEST == 0
#include "MMFCppFunctions.hpp"
#include "MMFCFunctions.h"
#include <thread>

int main() {
    std::thread t1(&MMFCppFunctions::helloFromCpp);
    std::thread t2(helloFromC);
    
    t1.join();
    t2.join();
    return 0;
}
#endif