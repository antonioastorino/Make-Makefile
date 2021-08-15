#include "common.h"
#if TEST == 1
#include "MMFCppFunctions.hpp"
#include "MMFCFunctions.h"
#include <iostream>
#include <thread>

int main()
{
    std::cout << "Hello from main-test" << std::endl;
    test_from_c();
    test_from_cpp();
    return 0;
}
#endif