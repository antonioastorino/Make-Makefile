#include "MMFCppFunctions.hpp"
extern "C" {
#include "MMFCFunctions.h"
}
#include <thread>

int main() {
    std::thread t1(&MMFCppFunctions::helloFromCpp);
    std::thread t2(helloFromC);
    
    t1.join();
    t2.join();
    return 0;
}