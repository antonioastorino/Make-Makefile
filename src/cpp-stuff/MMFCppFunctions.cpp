#include <iostream>
#include "MMFCppFunctions.hpp"
#include "common.h"

void MMFCppFunctions::helloFromCpp() {
	std::cout << "Hello from C++!\n";
}

#if TEST == 1
void test_from_cpp() {
	std::cout << "This is a test from C++" << std::endl;
	MMFCppFunctions::helloFromCpp();
}
#endif